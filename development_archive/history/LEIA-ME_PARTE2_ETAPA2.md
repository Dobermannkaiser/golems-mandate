# Square Village — Parte 2, Etapa 2

## Campanha de 120 dias e estações

Esta versão parte de `SquareVillage-Parte2-Etapa1-Fundacao-Corrigida`
e preserva a compatibilidade com o save da Parte 2.

### Campanha

- 120 dias de campanha;
- avaliações nos dias 20, 40, 60, 80, 100 e 120;
- metas provisórias de alimentação, material e felicidade;
- população preparada no catálogo, mas ainda não cobrada;
- janela de aprovação após as cinco primeiras avaliações;
- vitória após a sexta avaliação;
- opção de continuar no Modo Livre após a vitória;
- no Modo Livre, as estações e acontecimentos continuam, sem novas
  avaliações e sem apagar a vitória por causa de uma crise posterior.

### Metas provisórias

| Dia | Alimentação | Material | Felicidade |
| ---: | ---: | ---: | ---: |
| 20 | 55 | 25 | 60 |
| 40 | 75 | 40 | 60 |
| 60 | 100 | 55 | 65 |
| 80 | 125 | 70 | 65 |
| 100 | 150 | 90 | 70 |
| 120 | 180 | 110 | 75 |

### Estações

- Primavera: +10% de alimentação e +10% de manutenção de material;
- Verão: +20% de alimentação e +10% de redução diária de felicidade;
- Outono: +10% de alimentação e +15% de material;
- Inverno: -20% de alimentação e +20% de consumo de alimentação.

Os efeitos aparecem na previsão e são usados pelo mesmo cálculo que encerra
o dia. A paleta da interface, o fundo e o terreno da vila mudam junto com a
estação.

### Dicas de transição

Quando restam dez dias completos para a próxima estação, uma janela mostra:

- o nome da estação que está chegando;
- seus modificadores;
- uma dica estratégica exclusiva.

Há dicas para Primavera, Verão, Outono e Inverno. A transição já exibida é
salva para não reaparecer depois de carregar a mesma campanha.

### Acontecimentos

Os 12 acontecimentos genéricos foram preservados. Foram adicionados oito:

- Primavera: `Canteiros Alagados` e `Enxame de Polinizadores`;
- Verão: `Onda de Calor` e `Noite dos Vaga-lumes`;
- Outono: `Ventos da Colheita` e `Feira das Folhas`;
- Inverno: `Estrada Bloqueada pela Neve` e `Lago Congelado`.

Cada um só entra no sorteio durante sua própria estação. A chance diária e a
proteção contra longos períodos sem acontecimento continuam iguais.

## Roteiro de teste

1. Importe o `project.godot` desta pasta e execute com `F5`.
2. Inicie uma nova campanha.
3. Confirme no topo:
   - `DIA 1/120 — PRIMAVERA 1/30`;
   - próxima avaliação no dia 20;
   - metas 55, 25 e 60 na janela de avaliação.
4. Troque profissões e confirme que a previsão mostra o efeito da Primavera.
5. Salve, carregue e use `CONTINUAR`.
6. Ao concluir o dia 20:
   - resolva primeiro qualquer acontecimento pendente;
   - confirme a aprovação ou derrota da avaliação;
   - confirme a dica de que o Verão chega em dez dias.
7. No dia 31, confirme a mudança para Verão e a nova paleta.
8. Durante cada estação, confira que os acontecimentos sazonais exibidos
   correspondem à estação atual.
9. Repita o teste de salvar e carregar próximo de uma troca de estação.
   A mesma dica não deve aparecer duas vezes.
10. Ao vencer o dia 120, escolha `CONTINUAR NO MODO LIVRE`.
11. Confirme que o dia 121 inicia uma nova Primavera e que não há novas
    avaliações obrigatórias.

## Compatibilidade

- o arquivo continua sendo `square_village_part2_save.json`;
- saves ativos da Etapa 1 são carregados normalmente;
- uma vitória antiga no antigo dia 20 é migrada para campanha ativa;
- recursos, profissões, construções, acontecimentos pendentes e
  configurações são preservados;
- o save da Parte 1 continua separado e não é lido.
