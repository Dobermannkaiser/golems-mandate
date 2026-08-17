# Golem's Mandate — otimização: índice O(1) de habitantes

## Base e escopo
- Origem: `v3.11.5`, arquivo único alterado: `scripts/GameManager.gd`.
- Nenhuma regra de balanceamento, save, UI ou conteúdo foi alterada.
- Godot não foi executado por mim; validação de runtime depende do teste manual do usuário.

## O que mudou

`_find_villager_by_representative_id()` fazia busca linear no array `villagers`
a cada chamada (7 pontos de chamada no arquivo). Foi adicionado um índice
`Dictionary` paralelo, `_villagers_by_representative_id`, que resolve a busca
em O(1).

### Pontos de mutação (únicos dois lugares que tocam o índice)
- `register_villager()`: adiciona a entrada no índice logo após
  `villagers.append(villager)`.
- `unregister_villager()`: remove a entrada do índice logo após
  `villagers.erase(villager)`, com checagem de identidade (só remove se a
  entrada no índice ainda for o mesmo objeto).

### Segurança
`_find_villager_by_representative_id()` mantém um **fallback de busca linear**
caso o índice não encontre o habitante — evita falha silenciosa se algum
caminho de mutação não coberto (que eu não encontrei nesta revisão) deixar o
índice dessincronizado. Nesse caso o resultado continua correto, só perde o
ganho de performance naquela chamada específica.

## Por que não mexi no cache de previsão/produção

`calculate_next_day_forecast()` e `calculate_total_production()` também são
recalculadas em múltiplos pontos (5 e 2, respectivamente), mas a composição
do Conselho (`get_active_council()`) é derivada lendo o estado de cada
`Villager` sob demanda, sem um ponto único de mutação. Cachear esse valor
exigiria localizar e sincronizar todos os pontos que alteram composição de
conselho, construções e passivas espalhados pelo arquivo — risco de
regressão desproporcional ao ganho, já que o recálculo em si é barato com a
população atual (máx. ~34). Decidi não implementar por ora.

## Teste recomendado
- Abrir o projeto no Godot 4.7.1 e confirmar que compila sem erros/warnings novos.
- Recrutar um habitante, verificar que aparece corretamente nas telas que
  dependem de `_find_villager_by_representative_id` (Conselho, projetos,
  marcos de produção, XP).
- Dispensar/perder um habitante e confirmar que ele não é mais encontrado
  por ID (sem crash, sem resíduo no índice).
- Salvar e carregar uma campanha em andamento, conferir que o índice é
  reconstruído corretamente ao recarregar os habitantes.

## Próximas etapas sugeridas
1. Limpeza rápida (dead code / duplicações) — pendente, sem achados novos até agora.
2. Fatiar `GameManager.gd` em managers menores — maior risco, fazer em partes pequenas.
