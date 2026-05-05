# Asset Index

This index tracks generated and placeholder assets for the prototype.

## Current Runtime State

- The playable prototype currently uses Godot-native `ColorRect`, `Polygon2D`, and `Label` placeholders.
- The next art pass should follow `docs/design/asset-production-brief-v0.1.zh.md`.
- Runtime integration details live in `docs/design/generated-asset-integration-v0.1.zh.md`.
- Keep raw AI outputs in `assets/originals/generated/`.
- Put cropped/import-ready runtime sprites in `assets/sprites/`.

## Target Runtime Assets

| ID | Runtime Path | Status | Notes |
| --- | --- | --- | --- |
| BG01 | `assets/sprites/classroom/bg01_main_classroom_reality.png` | integrated v1 | Main classroom background, resized to 960x540. Raw output kept in `assets/originals/generated/bg01_main_classroom_reality.png`. |
| BG03 | `assets/sprites/classroom/bg03_final_classroom_memory.png` | integrated v1 | Final memory classroom, resized to 960x540. Raw output kept in `assets/originals/generated/bg03_final_classroom_memory.png`. |
| OBJ02-A | `assets/sprites/classroom/obj02_blackboard_state_rough.png` | integrated v1 | Rough chalk writing state. |
| OBJ02-B | `assets/sprites/classroom/obj02_blackboard_state_photo.png` | integrated v1 | Photo review state; v2 should reduce readable text. |
| OBJ02-C | `assets/sprites/classroom/obj02_blackboard_state_final.png` | integrated v1 | Final memory state; v2 should reduce readable text. |
| CH01 | `assets/sprites/characters/ch01_surveyor_player_sheet.png` | integrated v1 | 3x4 runtime sheet, 48x64 cells. Raw chroma-key output kept in `assets/originals/generated/ch01_surveyor_player_sprite_chromakey.png`; uncropped alpha sheet kept beside runtime sheet for review. |
| OBJ05 | `assets/sprites/objects/obj05_paper_plane_broken_pencil.png` | integrated v1 | Paper plane, broken pencil, desk leg. Raw chroma-key and alpha outputs kept in `assets/originals/generated/`. |
| OBJ06 | `assets/sprites/objects/obj06_archive_father_record.png` | integrated v1 | Archive cabinet, roster, old photo. v2 can reduce roster text clarity. |
| OBJ08 | `assets/sprites/objects/obj08_essay_fragment.png` | integrated v1 | Essay fragment and desk drawer for He Xiaoman memory. |
| AUDIO-PROC | `scripts/audio_controller.gd` | integrated v1 | Procedural placeholder ambience and SFX: classroom wind, paper record, shutter, memory swell, drawer, final tone. Replace with authored audio later. |

## Placeholder Directories

- `assets/placeholders/classroom/`
- `assets/placeholders/characters/`
- `assets/placeholders/overlays/`
- `assets/placeholders/ui/`
