# Contributing to Golem's Mandate

Thank you for considering a contribution to Golem's Mandate.

Golem's Mandate is a narrative village-management game developed with Godot 4 and extensive AI-assisted development.

Contributions are welcome when they improve the project in a clear, focused and verifiable way.

## Project Requirements

The current stable project uses:

- **Godot Engine 4.7**
- **GDScript**
- **GL Compatibility** rendering mode

The configured main scene is:

`res://scenes/main.tscn`

Before proposing technical changes, make sure they are compatible with the current project structure and Godot version.

## Types of Contributions

Useful contributions may include:

- bug fixes;
- documentation corrections;
- UI and accessibility improvements;
- gameplay or balance improvements;
- testing and regression coverage;
- code clarity improvements;
- fixes to save/load behavior;
- narrative or content corrections;
- technical cleanup with a clear benefit.

Large redesigns or changes to core systems should preferably be discussed before implementation.

## Before Making Changes

Before modifying the project:

1. Read the main `README.md`.
2. Inspect the relevant scenes, scripts and tests.
3. Understand the current behavior before replacing it.
4. Keep the proposed change focused.
5. Avoid modifying unrelated systems.
6. Check whether the change can affect saves, progression or existing content.

Prefer the smallest change that solves the identified problem.

## Stable Project State

The repository currently documents `v3.11.7` as the stable project version.

A new change should not automatically be considered a new stable version simply because it works locally.

Version changes and stable releases should be intentional and explicitly documented.

## Testing

The repository contains testing material under:

```text
tests/
├── integration/
└── regression/
