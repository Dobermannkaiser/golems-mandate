# Square Village — Etapa 6

Esta versão acrescenta objetivos de campanha, vitória, derrota e reinício
sem alterar as fórmulas de produção, os 12 acontecimentos ou os cartões dos
habitantes.

## Objetivos de vitória

A campanha termina depois da resolução do dia 20. Para vencer, a vila precisa
terminar esse dia com todas estas metas:

- 55 de alimentação;
- 25 de material;
- 65 de felicidade;
- 20 dias concluídos.

Os recursos podem atingir as metas antes, mas precisam continuar disponíveis
quando o dia 20 for encerrado.

## Condições de derrota

- felicidade igual a zero ao fim de um dia;
- alimentação igual a zero ao fim de dois dias consecutivos;
- material igual a zero ao fim de dois dias consecutivos;
- chegar ao fim do dia 20 sem todas as metas de recursos.

Quando existe um acontecimento depois do encerramento do dia, a campanha só é
avaliada após a escolha ser resolvida. Assim, a consequência do acontecimento
faz parte do resultado daquele dia.

## Arquivos acrescentados

- `scripts/campaign/CampaignManager.gd`: metas, crises e resultado;
- `scripts/ui/CampaignWindow.gd`: tela de objetivos, vitória e derrota.

## Arquivos integrados

- `scripts/GameManager.gd`;
- `scripts/UIManager.gd`;
- `scripts/events/EventManager.gd`.

## Teste recomendado

1. Execute o projeto com `F5`.
2. Clique em `OBJETIVOS` e confira as quatro metas.
3. Encerre o dia 1 e resolva o acontecimento.
4. Confirme que o contador de dias e metas foi atualizado.
5. Continue a campanha até o resultado final.
6. Na tela final, teste `OBSERVAR A VILA`.
7. Abra `OBJETIVOS` novamente e teste `NOVA CAMPANHA`.
8. Confirme que o jogo voltou ao dia 1 com recursos e habitantes reiniciados.
