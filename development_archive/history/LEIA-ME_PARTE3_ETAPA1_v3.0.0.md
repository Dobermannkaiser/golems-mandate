# Golem's Mandate — Parte 3, Etapa 1 — v3.0.0

Esta versão inicia a Parte 3 sobre uma cópia integral da base estável v2.10.1.
A base original não foi sobrescrita.

## Objetivo desta etapa

Criar a fundação persistente e diagnosticável necessária para as próximas etapas sem alterar ainda o funcionamento visível das construções, cartas, XP, passivas ou variantes.

## Implementado

- nome público alterado para **Golem's Mandate**;
- versão do projeto alterada para **3.0.0**;
- save exclusivo da Parte 3, com schema `golems_mandate_part3` e versão 8;
- saves da Parte 2 não são procurados nem convertidos automaticamente;
- seção `part3_foundation` obrigatória no save;
- semente persistente de campanha, preparada para geração procedural controlada;
- histórico diário de produção, custos, faltas, população, estações e composição profissional;
- histórico sequencial de decisões importantes;
- registro inicial de escolhas de acontecimentos, relacionamentos, construções e trocas do Conselho;
- flags persistentes de acontecimentos para consequências futuras e cadeias narrativas;
- estado preparado de nível, XP, produção acumulada e histórico de profissões por conselheiro;
- estado preparado de fila de obras, incluindo a capacidade `1 + população ÷ 20` limitada a quatro canteiros e durações de 1/2/3 dias, sem ativar ainda o sistema da Etapa 2;
- registro irreversível preparado para variantes de construções, sem oferecer escolhas ainda;
- métricas internas para identificar concentração de profissões, faltas e padrões de decisão;
- nova verificação no Oráculo de Diagnóstico para a fundação da Parte 3.

## O que deliberadamente não foi ativado

- construções continuam instantâneas nesta versão;
- conselheiros ainda usam a apresentação e geração da Parte 2;
- XP não é concedido automaticamente;
- retornos decrescentes e sinergias não foram aplicados;
- nenhuma variante de construção pode ser escolhida pela interface;
- recrutamentos e novos personagens não foram implementados;
- fórmulas econômicas e metas permanecem iguais às da v2.10.1.

Essas limitações são intencionais. A Etapa 1 cria contratos de dados e diagnóstico; não antecipa sistemas das etapas seguintes.

## Compatibilidade de save

A Parte 3 exige nova campanha. O arquivo usado é:

`user://golems_mandate_part3_v3_save.json`

A v2.10.1 permanece disponível separadamente para continuar campanhas antigas.

## Validação executada

- verificações estruturais de scripts, cenas e recursos;
- preservação dos sistemas e assets da Parte 2;
- validação da nova seção de save;
- validação dos pontos de integração do histórico e diagnóstico;
- integridade do ZIP e checksum SHA-256.

O executável do Godot não estava disponível neste ambiente. Portanto, esta entrega **não foi executada no motor** e ainda precisa do roteiro de teste manual.
