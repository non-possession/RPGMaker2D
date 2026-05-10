from pathlib import Path
from collections import deque

from PIL import Image


SRC = Path("assets/sprites/characters/ch01_surveyor_player_sheet.png")
OUT = Path("assets/sprites/characters/ch01_surveyor_player_sheet_v02.png")

COLS = 3
ROWS = 4
FRAME_W = 48
FRAME_H = 64
TARGET_VISIBLE_H = 56
TARGET_CENTER_X = 24
TARGET_BOTTOM_Y = 61
ALPHA_THRESHOLD = 8


def main() -> None:
    src = Image.open(SRC).convert("RGBA")
    out = Image.new("RGBA", (FRAME_W * COLS, FRAME_H * ROWS), (0, 0, 0, 0))
    for row in range(ROWS):
        for col in range(COLS):
            frame = src.crop((col * FRAME_W, row * FRAME_H, (col + 1) * FRAME_W, (row + 1) * FRAME_H))
            bbox = _largest_alpha_component_bbox(frame)
            if bbox is None:
                continue
            visible = frame.crop(bbox)
            next_w = max(1, round(visible.width * TARGET_VISIBLE_H / visible.height))
            visible = visible.resize((next_w, TARGET_VISIBLE_H), Image.Resampling.NEAREST)
            paste_x = col * FRAME_W + round(TARGET_CENTER_X - next_w / 2)
            paste_y = row * FRAME_H + TARGET_BOTTOM_Y - TARGET_VISIBLE_H
            out.alpha_composite(visible, (paste_x, paste_y))
    OUT.parent.mkdir(parents=True, exist_ok=True)
    out.save(OUT)
    print(f"wrote {OUT}")


def _largest_alpha_component_bbox(frame: Image.Image):
    alpha = frame.getchannel("A")
    pixels = alpha.load()
    visited = set()
    best = None
    best_count = 0
    for y in range(FRAME_H):
        for x in range(FRAME_W):
            if (x, y) in visited or pixels[x, y] <= ALPHA_THRESHOLD:
                continue
            queue = deque([(x, y)])
            visited.add((x, y))
            count = 0
            min_x = max_x = x
            min_y = max_y = y
            while queue:
                px, py = queue.popleft()
                count += 1
                min_x = min(min_x, px)
                max_x = max(max_x, px)
                min_y = min(min_y, py)
                max_y = max(max_y, py)
                for nx, ny in ((px - 1, py), (px + 1, py), (px, py - 1), (px, py + 1)):
                    if nx < 0 or nx >= FRAME_W or ny < 0 or ny >= FRAME_H:
                        continue
                    if (nx, ny) in visited or pixels[nx, ny] <= ALPHA_THRESHOLD:
                        continue
                    visited.add((nx, ny))
                    queue.append((nx, ny))
            if count > best_count:
                best_count = count
                best = (min_x, min_y, max_x + 1, max_y + 1)
    return best


if __name__ == "__main__":
    main()
