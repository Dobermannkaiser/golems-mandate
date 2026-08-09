# Golem’s Mandate — Parte 3 / Etapa 3 — v3.2.2

Correção de inicialização sobre a v3.2.1.

## Erro corrigido

A v3.2.1 chamava `_refresh_villager_cards()` ao alterar a profissão de uma carta, mas a função não havia sido criada em `UIManager.gd`. O Godot detectava isso como erro de parse e interrompia o carregamento de `UIManager.gd` e `UIManagerVariantB.gd`.

A v3.2.2:

- implementa `_refresh_villager_cards()`;
- atualiza todas as cartas após uma mudança de profissão;
- sincroniza também o seletor externo de profissão com os seletores das cartas;
- mantém as correções anteriores de legibilidade, profissões, Orion e modo de teste de relações;
- amplia o verificador para detectar chamadas privadas sem função correspondente.

## Avisos da fonte

As mensagens sobre `alagard.ttf` ser uma fonte pixel e ter subpixel positioning/hinting desativados são avisos informativos do Godot, não erros de inicialização.

## Validação

O projeto passou pelo verificador estrutural atualizado e pela simulação procedural. O Godot não foi executado neste ambiente; a validação final de runtime e interface depende do teste do usuário.
