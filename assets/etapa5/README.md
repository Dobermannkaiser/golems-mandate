# Stage 5 Visual Assets

This directory contains visual assets introduced during an earlier development stage of Golem's Mandate.

The directory name `etapa5` is historical and has been intentionally preserved to avoid unnecessary changes to existing Godot resource paths.

## Contents

The directory includes game visuals such as:

- building progression images;
- seasonal ground textures;
- village and square visuals;
- small environmental or character-related assets;
- Godot `.import` metadata associated with the source images.

The exact contents may evolve independently from the historical directory name.

## Why the Directory Was Not Renamed

Godot import metadata references resources using their current paths.

For example, files in this directory may reference locations such as:

```text
res://assets/etapa5/<asset-name>.png
```

Renaming or moving this directory could therefore require resource-path updates, reimporting and runtime validation.

Because the current project is a known stable version, the historical directory name is preserved unless there is a concrete technical reason to migrate it.

## Maintenance

When adding or modifying assets in this directory:

- preserve existing resource paths when possible;
- do not manually edit generated `.import` metadata unless there is a specific technical reason;
- consider scene, script and resource references before moving files;
- validate path changes in Godot when a migration is actually required.

The directory name should not be interpreted as meaning that these assets are obsolete or limited to an old playable version.

---

**◈ Dobermannkaiser**  
*Imagine freely. Build relentlessly.*
