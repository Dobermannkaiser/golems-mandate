# Development Archive

This directory contains historical development material preserved from earlier stages of Golem's Mandate.

The files stored here are kept for reference, documentation and development history.

They should **not** normally be treated as current production code or authoritative project documentation.

## Structure

```text
development_archive/
├── .gdignore
├── history/
└── templates/
```

### `history/`

Contains historical development material from earlier stages of the project.

These files may describe previous implementations, plans, versions or development decisions that no longer represent the current stable project.

### `templates/`

Contains historical or development-support templates preserved for reference.

Templates stored here should not automatically be interpreted as active project configuration.

### `.gdignore`

Prevents Godot from importing or processing the archived material as part of the active project.

## Current Project

For the current project state, use the files in the repository root and the active project directories such as:

- `scenes/`
- `scripts/`
- `assets/`
- `characters/`
- `tests/`
- `tools/`

The current stable project version is documented in the main [`README.md`](../README.md).

## Why Keep the Archive?

The archive is intentionally preserved because historical material can help explain how systems evolved and provide useful context for future maintenance.

Keeping it separate from active production files makes that history available without presenting it as part of the current implementation.

---

**◈ Dobermannkaiser**  
*Imagine freely. Build relentlessly.*
