#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def strip_comments_and_strings(text: str) -> str:
    output: list[str] = []
    index = 0
    quote: str | None = None
    triple = False
    escaped = False
    while index < len(text):
        char = text[index]
        if quote is not None:
            if triple and text.startswith(quote * 3, index):
                output.extend("   ")
                index += 3
                quote = None
                triple = False
                continue
            if not triple and not escaped and char == quote:
                output.append(" ")
                index += 1
                quote = None
                continue
            output.append("\n" if char == "\n" else " ")
            if not triple:
                if escaped:
                    escaped = False
                elif char == "\\":
                    escaped = True
            index += 1
            continue
        if char == "#":
            while index < len(text) and text[index] != "\n":
                output.append(" ")
                index += 1
            continue
        if char in {'"', "'"}:
            if text.startswith(char * 3, index):
                output.extend("   ")
                index += 3
                quote = char
                triple = True
            else:
                output.append(" ")
                index += 1
                quote = char
                escaped = False
            continue
        output.append(char)
        index += 1
    return "".join(output)


def extract_functions(text: str) -> list[tuple[str, str]]:
    matches = list(re.finditer(
        r"(?m)^(?:static\s+)?func\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(",
        text,
    ))
    result: list[tuple[str, str]] = []
    for index, match in enumerate(matches):
        end = matches[index + 1].start() if index + 1 < len(matches) else len(text)
        result.append((match.group(1), text[match.start():end]))
    return result


def get_signature(block: str) -> str:
    start = block.find("(")
    if start < 0:
        return ""
    depth = 0
    for index in range(start, len(block)):
        char = block[index]
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
            if depth == 0:
                return block[start:index + 1]
    return ""


def main() -> int:
    issues: list[str] = []
    script_count = 0
    function_count = 0

    for path in sorted(ROOT.rglob("*.gd")):
        script_count += 1
        raw = path.read_text(encoding="utf-8")
        clean = strip_comments_and_strings(raw)
        functions = extract_functions(clean)
        function_count += len(functions)
        if not functions:
            continue

        first_function = min(
            clean.find("func ") if "func " in clean else len(clean),
            clean.find("static func ") if "static func " in clean else len(clean),
        )
        top_level = clean[:first_function]
        class_variables = set(re.findall(
            r"(?m)^(?:@\w+(?:\([^\n]*\))?\s*)*(?:const|var)\s+"
            r"([a-z_][A-Za-z0-9_]*)",
            top_level,
        ))

        local_by_function: dict[str, set[str]] = {}
        for function_name, block in functions:
            signature = get_signature(block)
            parameters = set(re.findall(
                r"(?:\(|,)\s*([a-z_][A-Za-z0-9_]*)\s*(?::|,|\))",
                signature,
            ))
            declarations = set(re.findall(
                r"(?m)^\s*var\s+([a-z_][A-Za-z0-9_]*)",
                block,
            ))
            declarations.update(re.findall(
                r"(?m)^\s*for\s+([a-z_][A-Za-z0-9_]*)\s*(?::|\s+in)",
                block,
            ))
            declarations.update(parameters)
            local_by_function[function_name] = declarations

        all_local_names: set[str] = set()
        for names in local_by_function.values():
            all_local_names.update(names)

        for function_name, block in functions:
            declared_here = local_by_function[function_name]
            candidates = all_local_names - declared_here - class_variables
            for identifier in sorted(candidates):
                pattern = (
                    rf"(?<![.A-Za-z0-9_]){re.escape(identifier)}\b"
                    rf"(?!\s*\()"
                )
                if re.search(pattern, block):
                    issues.append(
                        f"{path.relative_to(ROOT).as_posix()}::{function_name}: "
                        f"'{identifier}' parece ser uma variável local de outro escopo."
                    )

    print("Golem's Mandate — verificação heurística de escopo local GDScript")
    print(f"Scripts analisados: {script_count}")
    print(f"Funções analisadas: {function_count}")
    print(f"Possíveis vazamentos de escopo: {len(issues)}")
    if issues:
        for issue in issues:
            print(f"- {issue}")
        return 1
    print("Resultado: APROVADO")
    return 0


if __name__ == "__main__":
    sys.exit(main())
