# Square Village — Parte 2, Etapa 7

## História e acontecimentos principais — v2.7.1

Esta versão transforma a campanha de 120 dias em uma história dividida em prólogo, cinco capítulos de recrutamento e uma auditoria final.

## Estrutura da campanha

- **Prólogo:** reencarnação do protagonista como Golem de Pedregulho, encontro com Sanctuary-Void, habilidade Prefeito Perfeito, chegada à vila e apresentação de Mimo e dos Passos-Leves.
- **Dia 20 — A Forja das Brasas Claras:** chegada de Aelric Brasa-Clara, elfo ferreiro e futuro candidato romântico.
- **Dia 40 — O Contrato de Cobre-Fino:** chegada de Kobi Cobre-Fino e abertura de uma rota comercial encantada.
- **Dia 60 — A Fissura que Sonhava:** chegada de Orion Escamagelo e investigação de uma anomalia de mana.
- **Dia 80 — O Arquivo sob as Folhas:** chegada de Rubra Verbum e descoberta de uma biblioteca mágica.
- **Dia 100 — A Caçada da Neve Rúnica:** chegada de Brunna Ana e confronto com uma criatura encantada.
- **Dia 120 — A Auditoria das Quatro Estações:** escolha final antes da avaliação divina.

## Funcionamento dos capítulos

Cada capítulo acontece depois da produção e dos custos do dia, mas antes da avaliação da campanha. O fluxo é:

1. diálogo introdutório obrigatório;
2. acontecimento principal com três decisões;
3. aplicação das consequências de gestão;
4. entrada do novo NPC;
5. diálogo de encerramento;
6. avaliação da campanha.

As escolhas especiais podem exigir construções, profissões ou aliados recrutados. As alternativas arriscadas usam atributos de um representante. A habilidade Prefeito Perfeito continua mostrando custos, requisitos e probabilidades pela interface do acontecimento.

## Persistência

O save v5 registra:

- prólogo concluído;
- capítulos concluídos;
- escolhas realizadas;
- flags narrativas;
- NPCs recrutados;
- diálogo ou acontecimento principal pendente;
- afinidade inicial causada pelas escolhas.

A versão usa o arquivo separado `square_village_part2_v2_7_0_save.json`. Uma campanha nova é necessária.

## Eventos comuns

Os 40 acontecimentos aleatórios anteriores continuam disponíveis com chance de 52,5%. Eventos sem estação exclusiva recebem contexto mágico diferente na primavera, verão, outono e inverno.

## Testes internos

O Oráculo de Diagnóstico possui seleção direta para:

- Prólogo;
- Dia 20;
- Dia 40;
- Dia 60;
- Dia 80;
- Dia 100;
- Dia 120.

O modo de teste libera recursos e requisitos temporariamente e restaura o estado da campanha após o encerramento, sem salvar alterações de teste.
