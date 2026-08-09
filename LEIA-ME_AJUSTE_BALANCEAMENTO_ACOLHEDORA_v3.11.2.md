# Golem's Mandate — ajuste de balanceamento Acolhedora — v3.11.2

Esta candidata foi criada em cópia separada da `v3.11.1`, preservando a base estável oficial `v3.10.1`. O ajuste responde ao teste manual em que o modo **Acolhedor** permaneceu punitivo demais no começo da campanha.

## O que mudou

Somente a dificuldade Acolhedora foi facilitada:

| Regra | v3.11.1 | v3.11.2 |
|---|---:|---:|
| Alimentação inicial | 44 | 48 |
| Material inicial | 18 | 22 |
| Felicidade inicial | 70 | 72 |
| Metas de alimentação | 85% da Moderada | 80% da Moderada |
| Metas de material | 85% da Moderada | 80% da Moderada |
| Meta de felicidade | Moderada − 6 | Moderada − 8 |
| Meta de população | multiplicador de 95% | um habitante a menos |
| Derrota com alimentação/material zerado | 3 dias seguidos | 4 dias seguidos |
| Recuperação de felicidade após crise | +1,5 | +2,0 |

A atração continua exigindo dois dias favoráveis e o abandono continua exigindo quatro dias preocupantes.

## Metas Acolhedoras

| Avaliação | Alimentação | Material | Felicidade | População |
|---:|---:|---:|---:|---:|
| Dia 20 | 40 | 18 | 45 | 10 |
| Dia 40 | 60 | 30 | 47 | 14 |
| Dia 60 | 84 | 44 | 49 | 19 |
| Dia 80 | 108 | 58 | 50 | 24 |
| Dia 100 | 132 | 66 | 47 | 29 |
| Dia 120 | 160 | 78 | 46 | 34 |

No dia 20, a capacidade inicial de moradia 10 agora basta para a meta. A casa continua útil para crescer além disso, mas deixa de ser uma obrigação imediata do modo Acolhedor.

## Transparência

O Guia foi corrigido: Acolhedora não reduz custos nem aumenta produção. Produção, consumo, manutenção, desgaste e custos de construção continuam neutros nas três dificuldades. A tela interna de balanceamento agora também mostra reservas iniciais, tolerância a crise e recuperação.

## Saves

- O envelope global continua na versão `18`.
- O schema da campanha continua `5`.
- Não existe migração nova.
- Saves Acolhedores em andamento passam a usar as metas, a tolerância e a recuperação novas, pois essas regras são calculadas pelo ID da dificuldade.
- As reservas iniciais maiores valem apenas para campanhas novas; nenhum recurso é injetado retroativamente em saves existentes.

## Escopo preservado

- Moderada e Difícil não foram rebalanceadas.
- Economia diária, construções, acontecimentos, relações, geração procedural e conteúdo narrativo não foram alterados.
- A simulação extensa dos 120 dias não foi executada.
- O Godot não foi executado; a validação de runtime continua dependente do teste manual do usuário.
