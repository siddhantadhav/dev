"""sysstat.py — system readings shared by scripts/system (bar module) and
scripts/sysinfo (detail window). Everything comes from /proc and /sys except
the NVIDIA GPU, which only nvidia-smi can report; that runs as one long-lived
`nvidia-smi -lms` stream rather than a process per sample.
"""
import os
import shutil
import subprocess
import threading
from pathlib import Path


class Cpu:
    """CPU busy % between consecutive calls to usage()."""

    def __init__(self):
        self.prev = self._read()

    @staticmethod
    def _read():
        fields = list(map(int, Path("/proc/stat").read_text().split("\n", 1)[0].split()[1:]))
        idle = fields[3] + fields[4]          # idle + iowait
        return sum(fields), idle

    def usage(self):
        total, idle = self._read()
        dt, di = total - self.prev[0], idle - self.prev[1]
        self.prev = (total, idle)
        return 0.0 if dt <= 0 else 100.0 * (dt - di) / dt


def cpu_freq_ghz():
    freqs = []
    for f in Path("/sys/devices/system/cpu").glob("cpu[0-9]*/cpufreq/scaling_cur_freq"):
        try:
            freqs.append(int(f.read_text()))
        except (OSError, ValueError):
            pass
    return sum(freqs) / len(freqs) / 1e6 if freqs else 0.0


def load_avg():
    return os.getloadavg()


def cpu_temp():
    """CPU package °C from coretemp (path survives hwmon renumbering)."""
    for f in Path("/sys/devices/platform/coretemp.0/hwmon").glob("hwmon*/temp1_input"):
        try:
            return int(f.read_text()) / 1000
        except (OSError, ValueError):
            pass
    return None


def memory():
    """(used GiB, total GiB, swap used GiB, swap total GiB)."""
    info = {}
    for line in Path("/proc/meminfo").read_text().splitlines():
        key, value = line.split(":", 1)
        info[key] = int(value.split()[0]) / 1024 ** 2   # kB → GiB
    used = info["MemTotal"] - info["MemAvailable"]
    return used, info["MemTotal"], info["SwapTotal"] - info["SwapFree"], info["SwapTotal"]


class Nvidia:
    """Latest reading from a background `nvidia-smi -lms` stream.
    .data is None when there's no NVIDIA GPU / driver."""

    FIELDS = ["name", "utilization.gpu", "memory.used", "memory.total",
              "temperature.gpu", "power.draw", "pstate"]

    def __init__(self, interval_ms=2000):
        self.data = None
        if not shutil.which("nvidia-smi"):
            return
        self.proc = subprocess.Popen(
            ["nvidia-smi", f"--query-gpu={','.join(self.FIELDS)}",
             "--format=csv,noheader,nounits", f"-lms={interval_ms}"],
            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
        threading.Thread(target=self._pump, daemon=True).start()

    def _pump(self):
        for line in self.proc.stdout:
            values = [v.strip() for v in line.split(",")]
            if len(values) != len(self.FIELDS):
                continue
            num = lambda v: None if v.startswith("[") else float(v)   # "[N/A]"
            self.data = {
                "name": values[0].removeprefix("NVIDIA ").removeprefix("GeForce "),
                "util": num(values[1]), "mem_used": num(values[2]), "mem_total": num(values[3]),
                "temp": num(values[4]), "power": num(values[5]), "pstate": values[6],
            }

    def close(self):
        proc = getattr(self, "proc", None)
        if proc:
            proc.terminate()


def intel_gpu():
    """Intel iGPU clock (MHz now, max). Its busy % is root-only; the clock
    is the honest unprivileged hint of how hard it's working."""
    for card in Path("/sys/class/drm").glob("card[0-9]"):
        try:
            if (card / "device/vendor").read_text().strip() != "0x8086":
                continue
            return int((card / "gt_act_freq_mhz").read_text()), int((card / "gt_max_freq_mhz").read_text())
        except (OSError, ValueError):
            continue
    return None


def battery():
    """dict(status, capacity, watts) — watts only while discharging, since
    on AC the battery reads 0 and nothing else measures total draw."""
    bat = next(iter(sorted(Path("/sys/class/power_supply").glob("BAT*"))), None)
    if bat is None:
        return None
    status = (bat / "status").read_text().strip()
    watts = None
    if status == "Discharging":
        try:
            watts = int((bat / "power_now").read_text()) / 1e6
        except (OSError, ValueError):
            try:   # some batteries report current + voltage instead
                watts = int((bat / "current_now").read_text()) * int((bat / "voltage_now").read_text()) / 1e12
            except (OSError, ValueError):
                pass
    return {"status": status, "capacity": int((bat / "capacity").read_text()), "watts": watts}


def power_profile():
    try:
        return subprocess.run(["powerprofilesctl", "get"], capture_output=True,
                              text=True, timeout=2).stdout.strip()
    except (OSError, subprocess.TimeoutExpired):
        return ""


def docker_running():
    """Running container names, or None when docker isn't usable."""
    if not shutil.which("docker"):
        return None
    try:
        out = subprocess.run(["docker", "ps", "--format", "{{.Names}}"], capture_output=True,
                             text=True, timeout=3)
    except (OSError, subprocess.TimeoutExpired):
        return None
    return out.stdout.split() if out.returncode == 0 else None
