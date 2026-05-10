# Project Agent Notes

This project uses a focused set of Matt Pocock skills to plan and build a Godot 2D RPG Maker-style demo inspired by the mood, pacing, and investigative structure of Firework.

## Enabled Skills

- `grill-me`: interview and pressure-test the game concept before committing to implementation.
- `to-prd`: turn the settled conversation context into a compact product requirements document.
- `to-issues`: slice the PRD or plan into independently implementable vertical tasks.
- `tdd`: drive gameplay, state-machine, and interaction behavior with red-green-refactor loops where practical.
- `diagnose`: debug regressions through reproduce, minimise, hypothesise, instrument, fix, and regression-test.
- `improve-codebase-architecture`: periodically review project structure against the domain language and decisions.
- `setup-matt-pocock-skills`: scaffold or align project context, issue vocabulary, and decision-document layout if needed.
- `grill-with-docs`: challenge plans against existing context and ADRs once those docs exist.
- `zoom-out`: request a higher-level view when a system or code area becomes hard to reason about.

## Demo Workflow

- Use placeholder art first, but attach structured image descriptions for assets that should later be generated consistently with GPT-image or external AI art tools.
- Keep the first playable demo narrow: exploration, atmosphere, a small investigation loop, and one or two representative scripted moments.
- Prefer Godot-native 2D patterns and small vertical slices over broad infrastructure work.
- Record durable design decisions in project docs once they affect scene structure, asset pipelines, or narrative interaction rules.

## Godot Testing Rules

- Prefer CLI/headless commands over Computer Use.
- Do not use Computer Use unless explicitly requested.
- Do not repeatedly kill Godot processes without asking.
- Before running Godot GUI, explain why GUI is necessary.
- Prefer focused tests and minimal reproduction scenes.

## Git Rules

- For commit tasks, only inspect git status and diff summary unless asked to review full diff.
- Do not run tests, benchmarks, Computer Use, or broad project scans for simple commit-message tasks.
- If the user asks only to commit changes, perform the minimal git workflow.
