#!/usr/bin/env python3
import struct
import zlib
from pathlib import Path

W = H = 1024
raw = bytearray()

for y in range(H):
    raw.append(0)
    for x in range(W):
        t = (x + y) / (2 * (W - 1))
        r, g, b = int(15 + 10*t), int(45 + 55*t), int(80 + 75*t)

        if 180 <= x <= 844 and 220 <= y <= 720:
            inside = True
            if x < 250 and y < 290:
                inside = (x-250)**2 + (y-290)**2 <= 70**2
            elif x > 774 and y < 290:
                inside = (x-774)**2 + (y-290)**2 <= 70**2
            elif x < 250 and y > 650:
                inside = (x-250)**2 + (y-650)**2 <= 70**2
            elif x > 774 and y > 650:
                inside = (x-774)**2 + (y-650)**2 <= 70**2
            if inside:
                r, g, b = 245, 248, 252

        if 230 <= x <= 794 and 275 <= y <= 620:
            r, g, b = 25, 55, 90

        if 310 <= x <= 650 and (
            340 <= y <= 375 or 430 <= y <= 465 or 520 <= y <= 555
        ):
            r, g, b = 245, 248, 252

        for cy, color in (
            (357, (58, 200, 120)),
            (447, (255, 170, 55)),
            (537, (58, 200, 120)),
        ):
            if (x-700)**2 + (y-cy)**2 <= 26**2:
                r, g, b = color

        if 470 <= x <= 554 and 720 <= y <= 805:
            r, g, b = 245, 248, 252
        if 370 <= x <= 654 and 790 <= y <= 840:
            r, g, b = 245, 248, 252

        raw += bytes((r, g, b))

def chunk(kind, data):
    return (
        struct.pack(">I", len(data))
        + kind
        + data
        + struct.pack(">I", zlib.crc32(kind + data) & 0xffffffff)
    )

png = (
    b"\x89PNG\r\n\x1a\n"
    + chunk(b"IHDR", struct.pack(">IIBBBBB", W, H, 8, 2, 0, 0, 0))
    + chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    + chunk(b"IEND", b"")
)

out = Path("OrderDisplay/Assets.xcassets/AppIcon.appiconset/AppIcon.png")
out.parent.mkdir(parents=True, exist_ok=True)
out.write_bytes(png)
print(f"Generated {out} ({len(png)} bytes, 1024x1024 RGB PNG)")
