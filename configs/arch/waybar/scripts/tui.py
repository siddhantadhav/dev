"""tui.py — the bits the waybar popups (calendar, weather) share: theme
colours, raw keyboard + mouse input, and drawing a full screen of lines.

Popups run inside a floating kitty (scripts/popup), so plain ANSI escapes
are enough — no curses.
"""
import json
import os
import re
import select
import sys
import termios
import tty
from pathlib import Path

_THEME = Path.home() / ".config/dev/theme/colors.json"
_FALLBACK = {"fg": "#cdd6f4", "fg_dim": "#a6adc8", "overlay": "#6c7086",
             "accent": "#cba6f7", "surface": "#313244", "red": "#f38ba8",
             "green": "#a6e3a1", "yellow": "#f9e2af", "blue": "#89b4fa",
             "cyan": "#74c7ec", "orange": "#fab387"}


def colours():
    try:
        return {**_FALLBACK, **json.loads(_THEME.read_text())}
    except (OSError, ValueError):
        return _FALLBACK


def fg(hex_):
    r, g, b = (int(hex_[i:i + 2], 16) for i in (1, 3, 5))
    return f"\x1b[38;2;{r};{g};{b}m"


def bg(hex_):
    r, g, b = (int(hex_[i:i + 2], 16) for i in (1, 3, 5))
    return f"\x1b[48;2;{r};{g};{b}m"


BOLD, RESET = "\x1b[1m", "\x1b[0m"
_ANSI = re.compile(r"\x1b\[[0-9;]*m")


def width(s):
    """Printed width of a line with colour codes in it."""
    return len(_ANSI.sub("", s))


def draw(lines, block=False):
    """Draw lines centred on screen — each on its own, or with block=True as
    one left-aligned block (for tables). Returns (top, lefts): the 1-based
    screen row of the first line and each line's 1-based start column, so
    callers can map mouse clicks back to what they drew."""
    cols, rows = os.get_terminal_size()
    top = max(0, (rows - len(lines)) // 2)
    if block:
        lefts = [max(0, (cols - max(map(width, lines))) // 2)] * len(lines)
    else:
        lefts = [max(0, (cols - width(line)) // 2) for line in lines]
    out = "\x1b[H\x1b[2J" + "\r\n" * top
    out += "\r\n".join(" " * left + line for left, line in zip(lefts, lines))
    sys.stdout.write(out)
    sys.stdout.flush()
    return top + 1, [left + 1 for left in lefts]


# --- input ------------------------------------------------------------------
# keys() yields: "left" "right" "up" "down" "q" "t" "r" ...,
# ("click", col, row) for a left click, "wheel-up"/"wheel-down" for scrolling.
_MOUSE = re.compile(r"\x1b\[<(\d+);(\d+);(\d+)([Mm])")
_ARROWS = {"\x1b[A": "up", "\x1b[B": "down", "\x1b[C": "right", "\x1b[D": "left",
           "h": "left", "l": "right", "k": "up", "j": "down"}


def keys(timeout=None):
    fd = sys.stdin.fileno()
    while True:
        ready, _, _ = select.select([fd], [], [], timeout)
        if not ready:
            yield "timeout"
            continue
        data = os.read(fd, 64).decode(errors="ignore")
        pos = 0
        while pos < len(data):
            m = _MOUSE.match(data, pos)
            if m:
                button, col, row, kind = int(m[1]), int(m[2]), int(m[3]), m[4]
                if button == 64:
                    yield "wheel-up"
                elif button == 65:
                    yield "wheel-down"
                elif button == 0 and kind == "M":
                    yield ("click", col, row)
                pos = m.end()
                continue
            for seq, name in _ARROWS.items():
                if data.startswith(seq, pos):
                    yield name
                    pos += len(seq)
                    break
            else:
                ch = data[pos]
                yield "q" if ch in ("\x1b", "\x03") else ch.lower()
                pos += 1


class Screen:
    """Alternate screen, hidden cursor, raw input with mouse reporting."""

    def __enter__(self):
        self.fd = sys.stdin.fileno()
        self.saved = termios.tcgetattr(self.fd)
        tty.setraw(self.fd)
        sys.stdout.write("\x1b[?1049h\x1b[?25l\x1b[?1000h\x1b[?1006h")
        sys.stdout.flush()
        return self

    def __exit__(self, *exc):
        sys.stdout.write("\x1b[?1006l\x1b[?1000l\x1b[?25h\x1b[?1049l")
        sys.stdout.flush()
        termios.tcsetattr(self.fd, termios.TCSADRAIN, self.saved)
