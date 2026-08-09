# Golem's Mandate — Parte 3 / Etapa 4 — correção v3.3.1

A v3.3.1 corrige os três problemas encontrados pelo usuário na candidata v3.3.0. A v3.3.0 não deve ser usada como base de continuação.

## 1. Conversas dos representantes agora têm consequência

As conversas decorativas e repetitivas foram retiradas do fluxo normal. Uma carta só abre conversa quando possui um assunto importante marcado com `!`.

Cada assunto:

- nasce da profissão atual do representante;
- apresenta um problema próprio da vila;
- oferece três decisões com custos e efeitos mostrados antes da escolha;
- inicia um projeto que dura dois ou três dias, incluindo o dia em que foi aceito;
- altera produção, consumo, manutenção ou felicidade;
- concede 6 XP ao representante quando o projeto termina;
- registra a decisão e o resultado na ficha histórica;
- usa uma reação coerente com a personalidade da carta.

Foram preparados 12 assuntos diferentes — dois para cada profissão — e 36 decisões com consequências. Um mesmo assunto não se repete dentro da mesma campanha. Enquanto houver um projeto em andamento, outro não é criado.

## 2. Indicadores de estado nas cartas

O canto superior direito da carta passa a comunicar duas pendências:

- selo vermelho `+N`: quantidade de pontos de atributo ainda não distribuídos;
- selo dourado `!`: existe um diálogo com decisão e consequência disponível.

Os indicadores usam texto e tooltip, não apenas cor. O ponto de atributo continua sendo distribuído na carta expandida.

## 3. Nível fixo das cartas recrutadas

As ofertas posteriores às avaliações agora seguem a progressão solicitada:

- Dia 20: nível 2;
- Dia 40: nível 3;
- Dia 60: nível 4;
- Dia 80: nível 5;
- Dia 100: nível 6;
- Dia 120: nível 6, respeitando o limite.

Os pontos correspondentes aos níveis anteriores já chegam distribuídos proceduralmente nos atributos. A carta recrutada começa com 0 XP no nível recebido e sem pontos pendentes artificiais.

## Persistência e compatibilidade

- versão do projeto: 3.3.1;
- versão do save: 13;
- versão da fundação da Parte 3: 3;
- é necessária uma campanha nova;
- oportunidades pendentes, projetos ativos, projetos concluídos e assuntos já usados são salvos.

## Validação realizada

- 612 verificações estruturais da Etapa 3: 0 falhas;
- 178 verificações estruturais da Etapa 4: 0 falhas;
- 10.000 campanhas simuladas para diálogos com consequência;
- 80.000 oportunidades iniciadas e 80.000 projetos concluídos;
- níveis de recrutamento confirmados em 2, 3, 4, 5, 6 e 6;
- regressões de cartas, XP, recrutamento, progressão, fila de obras e transparência aprovadas.

O Godot não foi baixado, instalado nem executado. Por determinação do usuário, a validação no motor é feita exclusivamente por ele.
