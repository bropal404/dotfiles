#!/usr/bin/env python3
"""Generate the warm-retro wallpapers as SVG, then render PNGs with rsvg-convert.

Stripes are drawn as concentric stroked arcs, so the curves are exact.
Run:  python3 make_retro_wallpaper.py
"""
import subprocess
from pathlib import Path

OUT = Path(__file__).resolve().parent
W, H = 3840, 2160

STRIPES = ["#e6d5b0", "#d9b24a", "#e08a2e", "#c0552b", "#7a3b26"]  # outer -> inner
SW, GAP = 56, 16          # stripe width, gap between stripes
Y0 = 1320                 # top edge of outer stripe
CX = 3040                 # x where the bend starts
R_OUT = 480               # outer edge radius of the bend
CY = Y0 + R_OUT           # bend centre y

CHIP = [
    "..#.#.#.#..",
    ".#########.",
    "##.......##",
    ".#.#####.#.",
    "##.#...#.##",
    ".#.#####.#.",
    "##.......##",
    ".#########.",
    "..#.#.#.#..",
]
PROMPT = [
    "#.........",
    ".#........",
    "..#.......",
    ".#........",
    "#...######",
]


def pixels(rows, ox, oy, s, color):
    out = []
    for j, row in enumerate(rows):
        for i, ch in enumerate(row):
            if ch == "#":
                out.append(f'<rect x="{ox + i * s}" y="{oy + j * s}" width="{s}" height="{s}" fill="{color}"/>')
    return "\n".join(out)


def stripe_paths():
    out = []
    for i, color in enumerate(STRIPES):
        d = i * (SW + GAP) + SW / 2          # centreline distance from outer edge
        r = R_OUT - d
        y = Y0 + d
        out.append(
            f'<path d="M -20 {y} H {CX} A {r} {r} 0 0 1 {CX + r} {CY} V {H + 20}" '
            f'fill="none" stroke="{color}" stroke-width="{SW}" stroke-linecap="butt"/>'
        )
    return "\n".join(out)


def svg(with_stripes):
    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">
<defs>
  <linearGradient id="bg" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#221d17"/>
    <stop offset="1" stop-color="#13100d"/>
  </linearGradient>
  <pattern id="scan" width="8" height="8" patternUnits="userSpaceOnUse">
    <rect width="8" height="2" fill="#000" fill-opacity="0.12"/>
  </pattern>
</defs>
<rect width="{W}" height="{H}" fill="url(#bg)"/>
{stripe_paths() if with_stripes else ""}
{pixels(CHIP, 192, 176, 12, "#4a3f31")}
{pixels(PROMPT, 368, 224, 12, "#e08a2e")}
<rect width="{W}" height="{H}" fill="url(#scan)"/>
</svg>
'''


def build(with_stripes, name):
    svg_path = OUT / f"{name}.svg"
    png_path = OUT / f"{name}.png"
    svg_path.write_text(svg(with_stripes))
    subprocess.run(["rsvg-convert", "-o", str(png_path), str(svg_path)], check=True)
    print("wrote", svg_path, "and", png_path)


if __name__ == "__main__":
    build(True, "retro_stripes")
    build(False, "retro_plain")
