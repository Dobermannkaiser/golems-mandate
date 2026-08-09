# Golem's Mandate — Parte 3 / Etapa 4 — correção v3.3.2

A v3.3.1 continha um erro de escopo em `scripts/GameManager.gd`.
A variável local `active_projects_applied` era declarada em
`calculate_next_day_forecast()`, mas utilizada em `advance_day()`.
Como variáveis locais não atravessam funções, o Godot interrompia o parser com:

`Identifier "active_projects_applied" not declared in the current scope.`

## Correção

- removida a declaração incorreta de `calculate_next_day_forecast()`;
- a lista de projetos aplicados agora é obtida e declarada dentro de
  `advance_day()`, antes de ser utilizada no resumo diário;
- o dia consultado passou a ser explicitamente `completed_day`, preservando
  quais projetos realmente afetaram o dia encerrado;
- versão pública atualizada para v3.3.2;
- save permanece na versão 13, pois não houve alteração de estrutura;
- criado `tools/verify_gdscript_local_scope.py`, um verificador heurístico que
  procura variáveis locais utilizadas fora da função onde foram declaradas;
- o verificador da Etapa 4 agora executa essa checagem automaticamente.

## Limite da validação

O Godot não foi baixado, instalado nem executado. A validação foi feita somente
por análise estática, verificadores em Python, simulações e extração limpa do ZIP,
conforme a regra definida pelo usuário.
