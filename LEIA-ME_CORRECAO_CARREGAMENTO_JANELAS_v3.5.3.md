# Golem's Mandate — Parte 3, Etapa 6 — v3.5.3

## Objetivo

Esta revisão corrige uma regressão introduzida pela otimização de carregamento sob demanda da v3.5.1 e preservada na v3.5.2.

Ao clicar em **GERENCIAR**, o jogo podia solicitar uma dica contextual antes de a janela de tutorial ter sido criada. O método `_show_contextual_tutorial()` chamava `tutorial_window.show_tutorial(steps)` com `tutorial_window == null`, gerando o erro:

`Invalid call. Nonexistent function 'show_tutorial' in base 'Nil'.`

## Correção aplicada

- criada a função `_ensure_tutorial_window()`;
- o tutorial completo e o tutorial contextual agora garantem a criação da janela antes de usá-la;
- a criação valida a instância antes de adicioná-la à árvore;
- se a janela não puder ser criada, o fluxo é interrompido de forma segura com `push_error`, sem chamada sobre `Nil`;
- o alvo da dica contextual continua sendo revalidado após o `call_deferred`.

## Auditoria adicional

Foram revisadas as 15 janelas convertidas para carregamento sob demanda:

- acontecimentos;
- campanha;
- recrutamento;
- aviso de estação;
- construções;
- save;
- tutorial;
- Conselho;
- histórico do representante;
- detalhes da previsão;
- vila ampliada;
- diálogos;
- diagnósticos;
- relacionamentos;
- configuração do perfil.

A falha de criação ausente foi encontrada somente no tutorial contextual. Os demais fluxos já criavam a janela antes do primeiro uso ou protegiam o acesso com `is_instance_valid()`.

## Compatibilidade

- versão pública: `3.5.3`;
- save: versão `15`, sem alteração;
- não exige campanha nova em relação à v3.5.0, v3.5.1 ou v3.5.2;
- as dez artes novas das construções foram preservadas;
- economia, builds, diálogos, acontecimentos e balanceamento não foram alterados.

## Limite da validação

O projeto não foi executado no Godot. A validação realizada foi estática, por referências, verificadores de estrutura, escopo, carregamento sob demanda, sprites e integridade do ZIP.
