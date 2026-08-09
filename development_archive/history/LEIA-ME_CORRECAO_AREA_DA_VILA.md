# SquareVillage — correção da Área da Vila

Esta cópia corrige o desalinhamento dos quadrados, nomes e profissões dos
quatro moradores depois de iniciar uma campanha nova ou carregar uma campanha
salva.

## Causa

O agrupamento de reposicionamentos criado no passe de otimização podia executar
a atualização enquanto os contêineres da interface ainda possuíam uma altura
provisória. A Área da Vila terminava de crescer, mas os moradores continuavam
distribuídos no espaço anterior.

A conta também reservava uma área vertical maior que a necessária e centralizava
somente o quadrado, sem considerar o nome e a profissão abaixo dele.

## Correção

- o reposicionamento aguarda a conclusão do quadro de layout;
- qualquer mudança de tamanho da Área da Vila solicita uma nova distribuição;
- a área útil respeita o título e os marcadores das construções;
- cada célula centraliza o conjunto completo: quadrado, nome e profissão;
- nenhuma informação do save ou regra do jogo foi alterada.

## Teste recomendado

1. Execute o projeto com `F5`.
2. Inicie uma nova campanha.
3. Confirme que os quatro moradores formam uma grade 2 × 2 sem sobreposição.
4. Troque as profissões dos quatro moradores.
5. Salve a campanha e volte ao menu.
6. Carregue a campanha.
7. Confirme novamente a grade e os textos.
8. Feche o jogo, abra-o outra vez e use `CONTINUAR`.
9. Redimensione a janela, se estiver executando fora da visualização incorporada.

O arquivo de salvamento permanece `square_village_part2_save.json`, compatível
com a Parte 2 — Etapa 1 original.
