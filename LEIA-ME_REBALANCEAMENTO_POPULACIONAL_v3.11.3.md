# Golem's Mandate — rebalanceamento populacional — v3.11.3

Esta candidata foi criada a partir da `v3.11.2`, preservando a base estável oficial `v3.10.1`. O ajuste responde ao teste manual que mostrou crescimento populacional lento demais e metas de habitantes excessivas nas três dificuldades.

## O que mudou

A obtenção de habitantes foi facilitada sem criar habitantes automaticamente nem alterar casas, consumo ou produção:

| Dificuldade | Dias favoráveis por chegada | Felicidade mínima para atrair |
|---|---:|---:|
| Acolhedora | 1 | 52 |
| Moderada | 2 | 55 |
| Difícil | 2 | 58 |

Continuam sendo necessários:

- uma vaga de moradia;
- alimentação suficiente para o próximo dia;
- material suficiente para a próxima manutenção;
- ausência de falta de alimentação ou material no dia.

As regras de abandono permanecem inalteradas: quatro dias preocupantes na Acolhedora, três na Moderada e dois na Difícil.

## Metas populacionais

Todas as avaliações pedem menos habitantes:

| Avaliação | Acolhedora v3.11.2 → v3.11.3 | Moderada v3.11.2 → v3.11.3 | Difícil v3.11.2 → v3.11.3 |
|---:|---:|---:|---:|
| Dia 20 | 10 → 9 | 11 → 10 | 12 → 11 |
| Dia 40 | 14 → 12 | 15 → 13 | 16 → 14 |
| Dia 60 | 19 → 16 | 20 → 17 | 21 → 18 |
| Dia 80 | 24 → 20 | 25 → 21 | 27 → 23 |
| Dia 100 | 29 → 24 | 30 → 25 | 32 → 27 |
| Dia 120 | 34 → 28 | 35 → 29 | 37 → 31 |

A progressão continua crescente e preserva a ordem Acolhedora < Moderada < Difícil.

## Transparência

- O tutorial e o Guia informam os dias favoráveis e a felicidade mínima de cada dificuldade.
- A previsão populacional mostra a felicidade mínima no tooltip.
- O Teste Interno mostra os mesmos valores e o Oráculo valida as metas finais `28/29/31`.
- Previsão, resolução diária e avaliação leem as regras dos mesmos catálogos.

## Saves

- O envelope global continua na versão `18`.
- O schema da campanha continua `5` e o catálogo continua `4`.
- Não existe migração nova.
- Ao carregar, a campanha reaplica o tempo de atração definido pela dificuldade e limita com segurança qualquer progresso antigo ao novo alvo.
- As metas e a felicidade mínima são derivadas da dificuldade e mudam imediatamente em saves existentes.
- Nenhum save recebe habitantes, moradia ou recursos retroativamente.

## Escopo preservado

- Produção, consumo, manutenção, custos e reservas iniciais não foram alterados.
- Construções, acontecimentos, relações, recrutamento, geração procedural e conteúdo narrativo não foram alterados.
- A simulação extensa dos 120 dias não foi executada.
- O Godot não foi executado; a validação de runtime continua dependente do teste manual do usuário.
