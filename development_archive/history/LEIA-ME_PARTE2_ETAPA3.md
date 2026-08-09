# SquareVillage — Parte 2, Etapa 3

## População e moradia — v2.3.0

Esta versão ativa população e moradia como sistemas completos da
campanha. Ela deve ser iniciada como uma nova run: salvamentos das
versões anteriores não são convertidos nem carregados.

## Regras implementadas

- A vila começa com 8 habitantes e capacidade para 10.
- Os quatro representantes fazem parte da população total.
- Os demais habitantes são moradores comuns, sem cartões individuais.
- A população nunca pode cair abaixo dos quatro representantes.
- A vila começa com duas casas.
- Cada casa oferece cinco vagas.
- Casas podem ser construídas repetidamente.
- Os custos das novas casas são 8, 12, 16, 20, 24... de material.
- Três dias favoráveis acumulados atraem um novo habitante.
- Três dias preocupantes consecutivos fazem um habitante comum partir.
- Sem vagas, a atração fica pausada até a construção de uma casa.

Um dia é favorável quando há vaga, felicidade de pelo menos 60 e
reservas suficientes para sustentar o próximo dia.

Um dia é preocupante quando há falta de alimentação ou material,
felicidade abaixo de 40, população acima da capacidade ou reservas
insuficientes para o próximo dia.

## Economia dos habitantes comuns

Cada habitante comum:

- produz 1,6 de alimentação por dia em pequenos cultivos;
- produz 0,2 de material por dia em serviços e trocas locais;
- consome 2,0 de alimentação;
- exige 0,25 de material para manutenção;
- gera 0,12 de desgaste diário de felicidade.

Celeiro, Serraria, Poço, Muralha e modificadores sazonais também afetam
essa economia. Os quatro representantes continuam sendo a principal
fonte de produção especializada.

## Metas populacionais

| Avaliação | População | Crescimento desde a meta anterior | Dias favoráveis necessários |
|---:|---:|---:|---:|
| Dia 20 | 10 | +2 | 6 |
| Dia 40 | 13 | +3 | 9 |
| Dia 60 | 16 | +3 | 9 |
| Dia 80 | 19 | +3 | 9 |
| Dia 100 | 22 | +3 | 9 |
| Dia 120 | 26 | +4 | 12 |

Cada capítulo possui 20 dias. Assim, as cinco primeiras metas exigem
entre 30% e 45% de dias favoráveis; a meta final exige 60%. Para chegar
a 26 habitantes são necessárias quatro casas adicionais, com custo
total de 56 materiais. Os valores foram mantidos porque oferecem margem
para eventos ruins sem tornar o crescimento automático.

Uma simulação determinística sem benefícios de eventos, usando
atributos médios dos representantes e cobrando casas, manutenção e
melhorias, alcançou todas as seis avaliações. As metas continuam
marcadas como provisórias para o teste real de jogo.

## Interface atualizada

- POPULAÇÃO mostra ocupação e capacidade no topo.
- A previsão mostra atração, risco, chegada, partida ou falta de vagas.
- HABITANTES passou a se chamar REPRESENTANTES.
- A janela de construções ganhou uma seção de moradia.
- A Área da Vila mostra a quantidade de casas.
- Objetivos agora exibem cinco requisitos, incluindo população.
- Menu, salvamento, carregamento e resumo diário mostram população,
  capacidade e casas.
- AJUDA E COMO JOGAR explica crescimento, abandono e economia local.

## Roteiro de teste

1. Inicie uma nova campanha.
2. Confirme POPULAÇÃO 8/10 e duas casas.
3. Ajuste as profissões até a previsão indicar ATRAÇÃO.
4. Complete três dias favoráveis e confirme a chegada de um morador.
5. Alcance 10/10 e confirme SEM VAGAS.
6. Construa uma casa por 8 materiais e confirme capacidade 15.
7. Salve, saia e use CONTINUAR.
8. Confirme população, capacidade, casas e medidores preservados.
9. Provoque três dias preocupantes e confirme uma partida.
10. Confira a meta populacional na avaliação do dia 20.

## Validação técnica

- esquema de save atualizado para a versão 3;
- catálogo e estado de campanha atualizados para a versão 3;
- saves antigos rejeitados de forma intencional;
- população e casas validadas em conjunto durante o carregamento;
- 28 scripts analisados;
- 27 referências internas verificadas;
- pacote final testado quanto à integridade.
