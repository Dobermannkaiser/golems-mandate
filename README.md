# Golem's Mandate

**A narrative village-management game built with Godot 4.**

<img width="1139" height="641" alt="Golem's Mandate gameplay" src="https://github.com/user-attachments/assets/e1c68a76-6228-4dbd-a31f-1244a43a6ae7" />

Golem's Mandate is a narrative management game about building a village, organizing a council and dealing with the long-term consequences of your decisions.

The project combines resource management, procedural characters, relationships, construction, seasonal evaluations and interconnected narrative events.

## Project Status

**Current stable version:** `v3.11.7`

The current repository contains the source project for the stable final version of Part 3.

The corresponding stable release is available here:

**[Golem's Mandate v3.11.7](https://github.com/Dobermannkaiser/golems-mandate/releases/tag/v3.11.7)**

The release includes the packaged source project as:

`GolemsMandate-v3.11.7-source.zip`

GitHub also provides its standard automatically generated source archives.

> **Note:** the current release contains the Godot source project. A prebuilt executable is not currently provided.

## Requirements

To open and run the project from source:

- **Godot Engine 4.7**
- GDScript support included with Godot
- a desktop environment capable of running Godot 4

The project currently uses Godot's **GL Compatibility** rendering mode.

## Running From Source

1. Download or clone this repository.
2. Open **Godot Engine 4.7**.
3. Choose **Import**.
4. Select the `project.godot` file from this repository.
5. Open the project.
6. Run the project normally from the Godot editor.

The configured main scene is:

```text
res://scenes/main.tscn
```

## Main Systems

Golem's Mandate currently includes:

- village management and progression;
- a council formed by procedural characters;
- construction queues and building development;
- economy and seasonal evaluations;
- chained narrative events and consequences;
- relationships, affinities and conflicts between characters;
- recruitment and character progression;
- professions, attributes and passive abilities;
- council synergies;
- difficulty modes and campaign statistics;
- internal forecasting and testing tools.

## Narrative and Characters

Characters are an important part of the project.

Council members can develop relationships, affinities and conflicts while participating in the development of the village.

Narrative events can create consequences that appear later in the campaign, allowing previous decisions to affect future situations.

The project is designed around systems that interact with one another rather than isolated events, allowing management decisions, relationships and narrative consequences to influence the same campaign over time.

## Testing

The repository contains development testing material organized under:

```text
tests/
├── integration/
└── regression/
```

These directories contain material used to verify interactions between systems and help identify regressions during development.

The presence of testing material does not mean that every possible configuration or environment has been automatically validated.

## Development Approach

Golem's Mandate was developed through an iterative process focused on:

- rapid prototyping;
- repeated testing;
- system refinement;
- balancing;
- documentation;
- AI-assisted development.

Development was performed progressively, with stable project states preserved between major implementation stages.

The repository also keeps selected historical development material for reference rather than mixing it with the active project structure.

## Artificial Intelligence

Artificial intelligence tools were used extensively throughout the development of this project.

Their use included:

- programming and code generation;
- architecture and system analysis;
- debugging support;
- documentation;
- testing support;
- balancing and iteration;
- workflow development;
- review and validation assistance.

The repository owner does not claim that all code or project material was manually authored.

The intention is to be transparent about the development process while focusing on the quality, usefulness, testability and reproducibility of the resulting project.

AI-assisted development does not remove the need for review and validation. Generated or suggested changes were treated as implementation material that still required inspection, testing or user validation when appropriate.

## Repository Structure

Some of the main directories include:

```text
assets/               Visual, audio and other game assets
characters/           Character-related data and content
scenes/               Godot scenes
scripts/              Game systems and GDScript code
tests/                Integration and regression testing material
tools/                Internal development and testing tools
development_archive/  Historical development material preserved for reference
```

Historical files inside `development_archive/` should not normally be treated as current production code or authoritative project documentation unless specifically indicated.

## Contributing

Contributions are welcome when they improve the project in a focused and verifiable way.

Before proposing changes, especially changes involving saves, project configuration, gameplay systems or stable-version behavior, please read:

**[CONTRIBUTING.md](CONTRIBUTING.md)**

The contribution guidelines explain project requirements, testing expectations, scope control, save compatibility and the use of AI-assisted development.

## License

To the extent permitted by law, all copyright and related rights that the repository owner can legally waive are dedicated to the public domain under **CC0 1.0 Universal**.

You may copy, modify, distribute and use this material, including commercially, without requesting permission and without an attribution requirement.

See [`LICENSE`](LICENSE) for the complete legal text.

CC0 applies only to rights that the repository owner actually possesses and can legally waive.

Third-party materials, if any, are not covered by this dedication and remain subject to the rights and licenses of their respective owners.

The project is provided without warranty.

---

**◈ Dobermannkaiser**  
*Imagine freely. Build relentlessly.*
