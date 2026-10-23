"""btstate.py — Bluetooth state from BlueZ, shared by scripts/bluetooth (bar
module) and scripts/bluetooth-menu. One D-Bus call (ObjectManager) returns
the adapter and every known device with its properties.
"""
import json
import subprocess

# BlueZ's Device1.Icon (freedesktop icon names) → nerd font glyph
ICONS = {
    "audio-headphones": "󰋋", "audio-headset": "󰋋",
    "audio-card": "󰓃", "audio-speakers": "󰓃",
    "input-keyboard": "󰌌", "input-mouse": "󰍽", "input-tablet": "󰓶",
    "input-gaming": "󰊴", "phone": "󰏲", "computer": "󰟀",
}
GENERIC = "󰂱"


def _value(props, key, default=None):
    v = props.get(key)
    return v["data"] if isinstance(v, dict) else default


def read():
    """(adapter, devices). adapter is None without a controller, else
    {"powered", "state"} where state is e.g. "on", "off", "off-blocked".
    devices: dicts of address, name, icon, connected, paired, battery."""
    try:
        out = subprocess.run(
            ["busctl", "--system", "--json=short", "call", "org.bluez", "/",
             "org.freedesktop.DBus.ObjectManager", "GetManagedObjects"],
            capture_output=True, text=True, timeout=3).stdout
        objects = json.loads(out)["data"][0]
    except (OSError, ValueError, KeyError, IndexError, subprocess.TimeoutExpired):
        return None, []

    adapter, devices = None, []
    for ifaces in objects.values():
        if "org.bluez.Adapter1" in ifaces and adapter is None:
            props = ifaces["org.bluez.Adapter1"]
            powered = _value(props, "Powered", False)
            adapter = {"powered": powered,
                       "state": _value(props, "PowerState", "on" if powered else "off")}
        if "org.bluez.Device1" in ifaces:
            props = ifaces["org.bluez.Device1"]
            devices.append({
                "address": _value(props, "Address", ""),
                "name": _value(props, "Alias") or _value(props, "Name") or _value(props, "Address", "?"),
                "icon": ICONS.get(_value(props, "Icon", ""), GENERIC),
                "connected": _value(props, "Connected", False),
                "paired": _value(props, "Paired", False),
                "battery": _value(ifaces.get("org.bluez.Battery1", {}), "Percentage"),
            })
    # connected first, then by name
    devices.sort(key=lambda d: (not d["connected"], d["name"].lower()))
    return adapter, devices
