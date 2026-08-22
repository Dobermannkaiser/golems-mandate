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

```text
res://scenes/main.tscn
```

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
```

When a contribution affects gameplay systems, saves, progression, economy, relationships, narrative logic or other interconnected systems, review the relevant tests and add or update regression coverage when appropriate.

Testing claims should describe only what was actually performed.

For example, distinguish between:

- static code or file inspection;
- review of existing tests;
- automated test execution;
- opening the project in Godot;
- running the project;
- manually reproducing a bug;
- manually validating changed behavior;
- save/load round-trip testing.

Static inspection does not prove that runtime behavior works correctly.

If a validation step was not performed, state that limitation clearly.

## Save Compatibility

Changes involving persistent state require additional care.

Before modifying save-related behavior, consider:

- existing save fields;
- newly introduced persistent fields;
- migrations;
- backwards compatibility;
- removed or renamed data;
- default values;
- loading older campaigns;
- saving and loading the changed state again.

Do not claim save compatibility unless it has actually been reviewed or tested.

If a contribution intentionally breaks compatibility, document that clearly.

## Project Configuration

Changes to files such as:

```text
project.godot
```

should be kept focused and justified.

Do not change the Godot version, rendering mode, physics engine, project identity, autoload structure or other global configuration merely as cleanup.

Configuration changes can affect the entire project and should be treated accordingly.

## AI-Assisted Contributions

AI-assisted contributions are welcome.

Artificial intelligence may be used for:

- programming;
- debugging;
- documentation;
- testing support;
- architecture analysis;
- code review;
- content analysis;
- workflow development.

However, AI-generated material should not automatically be treated as verified.

Contributors should review generated changes and clearly distinguish between:

- what was suggested by AI;
- what was inspected;
- what was actually tested;
- what remains uncertain.

Do not claim runtime validation, testing or compatibility checks that did not occur.

## Scope Control

Keep each contribution focused.

Avoid unrelated changes such as:

- broad reformatting;
- renaming unrelated files;
- reorganizing working systems without a clear reason;
- replacing established architecture unnecessarily;
- changing project-wide settings as part of an unrelated fix.

A smaller, focused change is easier to review, test and revert.

## Historical Development Material

The directory:

```text
development_archive/
```

contains historical development material preserved for reference.

Files inside that directory should not normally be treated as current production code or authoritative project documentation.

The active project is represented by the current files and directories in the repository root.

## Pull Requests

When opening a pull request:

1. describe the problem or goal;
2. summarize the changes;
3. identify the affected systems;
4. explain any save compatibility impact;
5. describe the validation actually performed;
6. mention known limitations or unresolved questions;
7. disclose AI assistance when applicable.

The repository includes a pull request template to help keep this information consistent.

## Bug Reports

When reporting a bug, provide the smallest reproducible sequence you can identify.

Useful information may include:

- game version;
- Godot version when running from source;
- operating system;
- affected system;
- steps to reproduce;
- expected behavior;
- actual behavior;
- relevant error messages;
- screenshots or logs;
- save-related context when applicable.

Do not include passwords, tokens, private information or sensitive files in public reports.

## Licensing and Submitted Material

By contributing, you should only submit material that you have the legal right to provide.

The repository uses **CC0 1.0 Universal** to the extent legally possible for rights the repository owner can legally waive.

Do not submit third-party copyrighted material unless its license or permission clearly allows the intended use and redistribution.

If third-party material is necessary, identify its origin and licensing terms clearly.

## Questions and Larger Proposals

For major architectural changes, substantial redesigns or changes that could affect multiple systems, discuss the proposal before implementing a large modification.

This helps avoid unnecessary work and protects the stable project state.

---

**◈ Dobermannkaiser**  
*Imagine freely. Build relentlessly.*
