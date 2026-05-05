#!/usr/bin/env python3
"""Soften readable text in generated story assets without changing layout.

The prototype needs blackboard and archive assets to imply writing and records,
not become literal reading puzzles. This script keeps the existing calibrated
asset sizes and anchors, while pushing text-heavy pixels back into chalk dust,
paper grain, and age stains.
"""

from __future__ import annotations

import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[2]

BLACKBOARD_ASSETS = [
    ROOT / "assets/sprites/classroom/obj02_blackboard_state_photo.png",
    ROOT / "assets/sprites/classroom/obj02_blackboard_state_final.png",
]
ARCHIVE_ASSET = ROOT / "assets/sprites/objects/obj06_archive_father_record.png"


def soften_blackboard(path: Path) -> None:
    image = Image.open(path).convert("RGBA")
    pixels = image.load()
    softened = image.copy()
    blurred = image.filter(ImageFilter.GaussianBlur(radius=1.15))
    blurred_pixels = blurred.load()
    rng = random.Random(path.name)

    # Interior only. Leave the frame, erasers, and chalk sticks crisp.
    text_rects = [
        (30, 13, 270, 52),
        (64, 24, 236, 61),
    ]

    for rect in text_rects:
        x0, y0, x1, y1 = rect
        for y in range(y0, y1):
            for x in range(x0, x1):
                r, g, b, a = pixels[x, y]
                if a < 20:
                    continue
                brightness = (r + g + b) / 3.0
                chalk_bias = brightness - min(r, g, b)
                if brightness < 92 and chalk_bias < 18:
                    continue
                br, bg, bb, ba = blurred_pixels[x, y]
                dust = rng.randint(-7, 8)
                board_r = max(30, min(102, int(r * 0.42 + br * 0.20 + dust)))
                board_g = max(45, min(116, int(g * 0.43 + bg * 0.21 + dust)))
                board_b = max(38, min(100, int(b * 0.40 + bb * 0.20 + dust)))
                softened.putpixel((x, y), (board_r, board_g, board_b, a))

    # Re-introduce a few broken chalk traces so the board still feels written on.
    draw = ImageDraw.Draw(softened, "RGBA")
    for _ in range(44):
        x = rng.randint(42, 258)
        y = rng.randint(18, 55)
        length = rng.randint(3, 11)
        color = (204, 190, 140, rng.randint(18, 42))
        draw.line((x, y, x + length, y + rng.randint(-1, 1)), fill=color, width=1)

    softened.save(path)


def soften_archive(path: Path) -> None:
    image = Image.open(path).convert("RGBA")
    softened = image.copy()
    rng = random.Random(path.name)

    # Roster sheet and old photo areas. The cabinet silhouette stays crisp.
    for rect, radius, tint in [
        ((37, 16, 99, 71), 1.25, (124, 104, 74)),
        ((43, 58, 92, 98), 1.45, (116, 91, 62)),
    ]:
        x0, y0, x1, y1 = rect
        crop = image.crop(rect).filter(ImageFilter.GaussianBlur(radius=radius))
        overlay = Image.new("RGBA", crop.size, tint + (58,))
        crop = Image.alpha_composite(crop, overlay)
        draw = ImageDraw.Draw(crop, "RGBA")
        for _ in range(28):
            x = rng.randint(0, crop.size[0] - 1)
            y = rng.randint(0, crop.size[1] - 1)
            draw.line(
                (x, y, min(crop.size[0] - 1, x + rng.randint(2, 8)), y),
                fill=(65, 48, 32, rng.randint(14, 34)),
                width=1,
            )
        softened.alpha_composite(crop, dest=(x0, y0))

    softened.save(path)


def main() -> None:
    for path in BLACKBOARD_ASSETS:
        soften_blackboard(path)
        print(f"softened blackboard text: {path.relative_to(ROOT)}")
    soften_archive(ARCHIVE_ASSET)
    print(f"softened archive text: {ARCHIVE_ASSET.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
