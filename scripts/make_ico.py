#!/usr/bin/env python3
from __future__ import annotations

import argparse
import struct
from pathlib import Path


PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"


def build_ico_from_png(png_bytes: bytes) -> bytes:
    # ICONDIR: reserved(2), type(2), count(2)
    header = struct.pack("<HHH", 0, 1, 1)
    # ICONDIRENTRY: width, height, color_count, reserved, planes, bpp, bytes, offset
    # width/height set to 0 means 256 for ICO.
    entry = struct.pack("<BBBBHHII", 0, 0, 0, 0, 1, 32, len(png_bytes), 22)
    return header + entry + png_bytes


def main() -> None:
    parser = argparse.ArgumentParser(description="Create a Windows .ico from a PNG.")
    parser.add_argument("source_png", help="Source PNG path")
    parser.add_argument("output_ico", help="Output ICO path")
    args = parser.parse_args()

    src = Path(args.source_png)
    out = Path(args.output_ico)
    if not src.exists():
        raise FileNotFoundError(f"Source PNG not found: {src}")

    png = src.read_bytes()
    if not png.startswith(PNG_SIGNATURE):
        raise ValueError(f"Source is not a PNG file: {src}")

    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_bytes(build_ico_from_png(png))
    print(f"Wrote {out}")


if __name__ == "__main__":
    main()
