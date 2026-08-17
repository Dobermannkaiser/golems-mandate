# Golem's Mandate — rebalanceamento de inverno — v3.11.4

Esta candidata foi criada a partir da `v3.11.3`, preservando a base estável oficial `v3.10.1`. O ajuste responde ao teste manual em que uma vila dedicada à alimentação ainda previa perda de `43,7` unidades por dia no inverno.

## Causa encontrada

O inverno aplicava simultaneamente:

- `−20%` à produção de alimentação;
- `+20%` ao consumo de alimentação.

Em uma economia equilibrada fora do inverno, a combinação abria uma pressão sazonal de 40 pontos percentuais. Por exemplo, produzir 100 e consumir 100 se transformava em produzir 80 e consumir 120: saldo `−40`.

## Regra nova

O inverno passa a aplicar:

- `−10%` à produção de alimentação;
- `+10%` ao consumo de alimentação.

No mesmo exemplo, produzir 100 e consumir 100 passa a produzir 90 e consumir 110: saldo `−20`. A pressão causada pela estação foi reduzida exatamente pela metade.

O saldo completo ainda considera produção real, população, construções, passivas, sinergias, acontecimentos e consumo normal. Por isso, um déficit que já existiria fora do inverno não é apagado nem dividido artificialmente.

## Integração

- A previsão e o avanço do dia continuam usando as mesmas fórmulas do `GameManager`.
- O resumo da estação informa `−10% / +10%`.
- O Guia do jogo explica os dois modificadores.
- O Teste Interno exige os valores novos.
- A regra vale igualmente nas três dificuldades.

## Saves

- O envelope global continua na versão `18`.
- O schema da campanha continua `5`.
- O catálogo continua `4`.
- Não existe migração nova.
- Saves em andamento recebem a regra nova assim que forem carregados.
- Nenhum recurso é concedido ou removido retroativamente.

## Escopo preservado

- Produção-base e consumo-base não foram alterados.
- Dificuldades, metas, população, construções, passivas, acontecimentos, relações e recrutamento não foram alterados.
- A simulação extensa dos 120 dias não foi executada.
- O Godot não foi executado; a validação de runtime continua dependente do teste manual do usuário.
