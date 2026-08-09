#!/usr/bin/env python3
from __future__ import annotations

from collections import defaultdict
from pathlib import Path
import hashlib
import re

ROOT = Path(__file__).resolve().parents[1]
FAILURES: list[str] = []
CHECKS = 0


def check(label: str, condition: bool, detail: str = "") -> None:
    global CHECKS
    CHECKS += 1
    if not condition:
        suffix = f": {detail}" if detail else ""
        FAILURES.append(label + suffix)


def read(relative: str) -> str:
    return (ROOT / relative).read_text(encoding="utf-8")


def runtime_text_files() -> list[Path]:
    result = [ROOT / "project.godot"]
    for folder in ["scripts", "scenes", "characters"]:
        result.extend(path for path in (ROOT / folder).rglob("*") if path.is_file())
    return result


def validate_resource_references() -> None:
    pattern = re.compile(r"res://[^\s\"'\)\],}]+")
    missing: dict[str, list[str]] = defaultdict(list)
    for path in runtime_text_files():
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        for raw_ref in pattern.findall(text):
            ref = raw_ref.rstrip(".,;:")
            target = ROOT / ref.removeprefix("res://")
            if not target.exists():
                missing[ref].append(path.relative_to(ROOT).as_posix())
    check("Todas as referências res:// existem", not missing, str(dict(missing)))


def validate_assets() -> None:
    active_files = [path for path in (ROOT / "assets").rglob("*") if path.is_file()]
    hashes: dict[str, list[Path]] = defaultdict(list)
    for path in active_files:
        if path.suffix.lower() in {".txt", ".md"}:
            continue
        hashes[hashlib.sha256(path.read_bytes()).hexdigest()].append(path)
    duplicate_groups = [group for group in hashes.values() if len(group) > 1]
    check("Não existem recursos binários duplicados", not duplicate_groups,
          str([[p.relative_to(ROOT).as_posix() for p in group] for group in duplicate_groups]))

    removed_paths = [
        "assets/relationships",
        "assets/dialogue/portraits/deusa_auditoria_provisoria.png",
        "assets/etapa5/alagard.ttf",
        "assets/etapa5/barn.png",
        "assets/etapa5/cat_sheet.png",
        "assets/etapa5/house.png",
        "assets/etapa5/path_dirt.png",
        "assets/etapa5/sawmill.png",
        "assets/etapa5/square.png",
        "assets/etapa5/well.png",
    ]
    for relative in removed_paths:
        check(f"Recurso obsoleto removido: {relative}", not (ROOT / relative).exists())

    check("Licenças de áudio preservadas", (ROOT / "assets/audio/LICENSES.txt").is_file())
    check("Fontes dos áudios preservadas", (ROOT / "assets/audio/SOURCES.txt").is_file())


def validate_scene_cleanup() -> None:
    main_scene = read("scenes/main.tscn")
    node_count = len(re.findall(r"^\[node ", main_scene, flags=re.MULTILINE))
    check("Cena principal possui apenas dez nós estruturais", node_count == 10, str(node_count))
    check("Painel legado removido", "ManagementPanel" not in main_scene)
    check("Fundo legado removido", 'name="Background"' not in main_scene)
    check("Chão legado removido", 'name="VillageGround"' not in main_scene)
    check("Contêiner de modelos de habitantes preservado", 'name="Villagers"' in main_scene)
    check("Modelos antigos começam ocultos", 'name="Villagers" type="Node2D" parent="World"' in main_scene and "visible = false" in main_scene)
    check("Mimo continua cadastrada na cena", 'representative_id = "passos_leves_faz_tudo"' in main_scene)


def validate_runtime_optimizations() -> None:
    ui = read("scripts/UIManager.gd")
    ready_match = re.search(r"func _ready\(\) -> void:\n(.*?)(?=\n\nfunc )", ui, flags=re.DOTALL)
    ready_body = ready_match.group(1) if ready_match else ""
    check("Função _ready da interface localizada", bool(ready_match))
    check("Menu inicial continua criado no startup", "_create_main_menu()" in ready_body)
    for method in [
        "_create_event_window()",
        "_create_campaign_window()",
        "_create_recruitment_window()",
        "_create_season_hint_window()",
        "_create_building_window()",
        "_create_save_window()",
        "_create_tutorial_window()",
        "_create_council_window()",
        "_create_councillor_history_window()",
        "_create_forecast_details_window()",
        "_create_village_window()",
        "_create_dialogue_window()",
        "_create_diagnostics_window()",
        "_create_relationships_window()",
        "_create_profile_setup_window()",
    ]:
        check(f"Janela adiada no startup: {method}", method not in ready_body)
    check("Layout legado não agenda quadros sem VillageGround",
          "if not is_instance_valid(village_ground):\n\t\treturn" in ui)

    catalog = read("scripts/dialogue/CharacterCatalog.gd")
    for marker in [
        "static var _cache_ready",
        "static var _definitions_cache",
        "static var _definitions_by_id",
        "static var _portrait_texture_cache",
        "static func _ensure_cache()",
        "ResourceLoader.load(path)",
    ]:
        check(f"Cache de personagens contém {marker}", marker in catalog)
    get_by_id = re.search(r"static func get_by_id.*?(?=\n\nstatic func )", catalog, flags=re.DOTALL)
    check("Busca de personagem usa índice em memória",
          bool(get_by_id) and "_definitions_by_id.get" in get_by_id.group(0))


def validate_project_metadata() -> None:
    project = read("project.godot")
    save_manager = read("scripts/save/SaveManager.gd")
    check("Versão pública é 3.8.2", 'config/version="3.8.2"' in project)
    check("Formato de save atual é 17", "const SAVE_VERSION: int = 17" in save_manager)
    check("Histórico está fora da árvore importável", (ROOT / "development_archive/.gdignore").is_file())
    check("Ferramentas estão fora da árvore importável", (ROOT / "tools/.gdignore").is_file())


def main() -> int:
    validate_project_metadata()
    validate_resource_references()
    validate_assets()
    validate_scene_cleanup()
    validate_runtime_optimizations()

    print("Golem's Mandate — auditoria de limpeza e otimização preservada — v3.8.2")
    print(f"Verificações: {CHECKS}")
    print(f"Falhas: {len(FAILURES)}")
    if FAILURES:
        for failure in FAILURES:
            print(f"- {failure}")
        return 1
    print("Resultado estrutural: APROVADO")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
