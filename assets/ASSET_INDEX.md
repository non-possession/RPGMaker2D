# Asset Index

This index tracks generated and placeholder assets for the prototype.

## Current Runtime State

- The playable prototype currently uses Godot-native `ColorRect`, `Polygon2D`, and `Label` placeholders.
- The next art pass should follow `docs/design/asset-production-brief-v0.1.zh.md`.
- Runtime integration details live in `docs/design/generated-asset-integration-v0.1.zh.md`.
- Reusable intake and licensing rules live in `docs/design/asset-pipeline-v0.1.zh.md`.
- v0.2 scale, layering, collision, and prop attachment rules live in `docs/design/first-space-scale-v0.2.zh.md`.
- Keep raw AI outputs in `assets/originals/generated/`.
- Put cropped/import-ready runtime sprites in `assets/sprites/`.

## v0.2 Scale Baseline

| Item | Approved Runtime Size | Notes |
| --- | --- | --- |
| Logical viewport | `960x540` | Continue using this as the design and integration coordinate space. |
| Player standing height | `56px` | Primary scale reference for classroom objects and collision. |
| Single desk | `72x42px` | Approved for focused investigation desks and desk-bound props. |
| Double desk | `112x44px` | Recommended default desk size for v0.2 classroom rows. |
| Double desk upper bound | `128x44px` | Use sparingly; can make the player feel too small. |
| Minimum walkable aisle | `64px` | Passable but not ideal for primary investigation flow. |
| Comfortable investigation aisle | `80-96px` | Preferred width for main player routes. |

## Target Runtime Assets

| ID | Runtime Path | Status | Notes |
| --- | --- | --- | --- |
| BG01 | `assets/sprites/classroom/bg01_main_classroom_reality.png` | integrated v1 | Main classroom background, resized to 960x540. Raw output kept in `assets/originals/generated/bg01_main_classroom_reality.png`. |
| BG03 | `assets/sprites/classroom/bg03_final_classroom_memory.png` | integrated v1 | Final memory classroom, resized to 960x540. Raw output kept in `assets/originals/generated/bg03_final_classroom_memory.png`. |
| OBJ02-A | `assets/sprites/classroom/obj02_blackboard_state_rough.png` | integrated v1 | Rough chalk writing state. |
| OBJ02-B | `assets/sprites/classroom/obj02_blackboard_state_photo.png` | integrated v2 | Photo review state; readable text softened into chalk traces while preserving writing density. |
| OBJ02-C | `assets/sprites/classroom/obj02_blackboard_state_final.png` | integrated v2 | Final memory state; readable text softened into warm chalk traces while preserving final-memory glow. |
| CH01 | `assets/sprites/characters/ch01_surveyor_player_sheet_v02.png` | integrated v0.2 | 3x4 runtime sheet, 48x64 cells, visible character pixels pre-scaled to 56px and aligned to a fixed foot pivot. Built from `assets/sprites/characters/ch01_surveyor_player_sheet.png` by `scripts/tools/build_v02_player_sheet.py`, using the largest connected body component so detached floor shadows do not shrink side-view frames. Raw chroma-key output kept in `assets/originals/generated/ch01_surveyor_player_sprite_chromakey.png`; uncropped alpha sheet kept beside runtime sheet for review. |
| OBJ05 | `assets/sprites/objects/obj05_paper_plane_broken_pencil.png` | integrated v1 | Paper plane, broken pencil, desk leg. Raw chroma-key and alpha outputs kept in `assets/originals/generated/`. |
| OBJ06 | `assets/sprites/objects/obj06_archive_father_record.png` | integrated v2 | Archive cabinet, roster, old photo. Roster/photo details softened so the player reads it as evidence, not a text puzzle. |
| OBJ08 | `assets/sprites/objects/obj08_essay_fragment.png` | integrated v1 | Essay fragment and desk drawer for He Xiaoman memory. |
| PORTRAIT-CONFIG | `data/portraits.gd` | integrated v1 | Config-driven dialogue portrait interface for protagonist, father, mother, and He Xiaoman. Uses fallback initials until final portrait art exists. |
| AUDIO-PROC | `scripts/audio_controller.gd` | integrated v1 | Procedural placeholder ambience and SFX: classroom wind, paper record, shutter, memory swell, drawer, final tone. Replace with authored audio later. |
| WALL-ANCHORS-P1 | `scripts/main.gd` | integrated v1 | Godot-native wall anchor props for A4 award, A5 closure notice, and A6 school plaque in generated-background mode. These clarify interaction targets without changing event order or dialogue. |

## Placeholder Directories

- `assets/placeholders/classroom/`
- `assets/placeholders/characters/`
- `assets/placeholders/overlays/`
- `assets/placeholders/ui/`
