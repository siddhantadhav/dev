"""mediastate.py — what's playing (playerctl) and where the sound goes
(pactl), shared by scripts/media (bar module) and scripts/mediactl (controls).
"""
import json
import os
import subprocess
import time
from pathlib import Path

_FIELDS = ["playerInstance", "playerName", "status", "title", "artist", "album",
           "position", "mpris:length"]
_FORMAT = "\t".join("{{%s}}" % f for f in _FIELDS)


def _run(*cmd):
    try:
        return subprocess.run(cmd, capture_output=True, text=True, timeout=3).stdout
    except (OSError, subprocess.TimeoutExpired):
        return ""


def _seconds(us):
    try:
        return int(us) / 1e6
    except ValueError:
        return None


def players():
    """Every MPRIS player: dicts of instance, name, status ("Playing" /
    "Paused" / "Stopped"), title, artist, album, position, length (seconds or
    None)."""
    out = []
    for line in _run("playerctl", "--all-players", "metadata", "--format", _FORMAT).splitlines():
        values = line.split("\t")
        if len(values) != len(_FIELDS):
            continue
        inst, name, status, title, artist, album, pos, length = values
        out.append({"instance": inst, "name": name, "status": status, "title": title,
                    "artist": artist, "album": album,
                    "position": _seconds(pos), "length": _seconds(length)})
    return out


class TrackClock:
    """Our own timing of each track, for players whose position is stale.
    Firefox (YouTube, notably) reports position 0 and no length for a new
    track until the page updates them, e.g. on pause or seek. While a
    player's position is stuck (under a second, or not moving while it
    plays), the clock's elapsed time stands in and the player is marked
    "estimated"; once the player reports moving numbers again, they win and
    re-sync the clock.

    scripts/media keeps it (it sees every track change) and saves it to
    $XDG_RUNTIME_DIR; scripts/mediactl loads it, so the popup agrees."""

    FILE = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / "waybar-media-tracks.json"
    STUCK = 1.5   # seconds a playing track's position may not move before it's stale

    def __init__(self):
        self.tracks = {}

    def load(self):
        try:
            self.tracks = json.loads(self.FILE.read_text())
        except (OSError, ValueError):
            pass

    def save(self):
        tmp = self.FILE.with_suffix(".tmp")
        tmp.write_text(json.dumps(self.tracks))
        tmp.replace(self.FILE)

    def apply(self, all_players, now=None):
        """Fill in position (and "estimated": True) where the player's own is
        stale. Tracks no longer playing anywhere are forgotten."""
        now = time.time() if now is None else now
        live = {}
        for p in all_players:
            key = "\t".join((p["instance"], p["title"], p["artist"]))
            playing, reported = p["status"] == "Playing", p["position"]
            t = self.tracks.get(key)
            if t is None:
                t = {"elapsed": reported if reported and reported >= 1 else 0.0,
                     "at": now, "playing": playing, "reported": reported, "reported_at": now}
            else:
                if t["playing"]:
                    t["elapsed"] += now - t["at"]
                t["at"], t["playing"] = now, playing
                # playerctl adds a few µs per read, so only a real step counts
                if (reported is None) != (t["reported"] is None) or (
                        reported is not None and abs(reported - t["reported"]) >= 0.5):
                    t["reported"], t["reported_at"] = reported, now
            stuck = playing and now - t["reported_at"] > self.STUCK
            if reported is not None and reported >= 1 and not stuck:
                t["elapsed"] = reported
            else:
                p["position"], p["estimated"] = t["elapsed"], True
            live[key] = t
        self.tracks = live


def current(all_players):
    """The player to show: a playing one, else a paused one, else any."""
    for status in ("Playing", "Paused"):
        for p in all_players:
            if p["status"] == status:
                return p
    return all_players[0] if all_players else None


def is_headphones(sink):
    props = sink.get("properties", {})
    kind = props.get("device.form_factor", "")
    icon = props.get("device.icon_name", "")
    port = sink.get("active_port") or ""
    return (kind in ("headphone", "headset", "hands-free")
            or "headphone" in icon or "headset" in icon or "headphones" in port)


def sinks():
    """Output devices: dicts of name, label, headphones, volume (%), mute,
    default. label is "Built-in Audio · Speakers" or the Bluetooth name."""
    default = _run("pactl", "get-default-sink").strip()
    try:
        raw = json.loads(_run("pactl", "-f", "json", "list", "sinks") or "[]")
    except ValueError:
        raw = []
    out = []
    for s in raw:
        props = s.get("properties", {})
        label = props.get("device.description") or s.get("description", s["name"])
        port = next((p for p in s.get("ports", []) if p["name"] == s.get("active_port")), None)
        if port and len(s.get("ports", [])) > 1:
            label += f" · {port['description']}"
        volumes = [int(v["value_percent"].rstrip("%")) for v in s.get("volume", {}).values()]
        out.append({"name": s["name"], "label": label, "headphones": is_headphones(s),
                    "volume": max(volumes) if volumes else 0, "mute": s.get("mute", False),
                    "default": s["name"] == default})
    return out


def default_sink(all_sinks):
    return next((s for s in all_sinks if s["default"]), all_sinks[0] if all_sinks else None)


def clock(seconds):
    if seconds is None:
        return "–:––"
    seconds = int(seconds)
    h, m, s = seconds // 3600, seconds // 60 % 60, seconds % 60
    return f"{h}:{m:02}:{s:02}" if h else f"{m}:{s:02}"
