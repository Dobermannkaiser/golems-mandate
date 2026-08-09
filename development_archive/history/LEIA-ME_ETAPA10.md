# SquareVillage — Etapa 10

## Tutorial e introdução da campanha

Esta versão parte da Etapa 9 testada e adiciona orientação para
novos jogadores sem alterar recursos, fórmulas, acontecimentos,
construções, objetivos ou formato do save.

## O que foi adicionado

- introdução automática na primeira nova campanha;
- sete etapas com destaque visual da área explicada;
- explicações de objetivos, recursos, previsão, habitantes,
  profissões, construções, acontecimentos e ciclo diário;
- botões `VOLTAR`, `PRÓXIMO`, `COMEÇAR` e `PULAR TUTORIAL`;
- opção `COMO JOGAR` no menu principal;
- botão `AJUDA` durante a partida;
- dicas breves no registro nas primeiras ações da campanha;
- progresso do tutorial separado do save da campanha;
- compatibilidade com o save criado nas Etapas 8 e 9.

O guia automático é mostrado apenas uma vez. Pular também registra
que o jogador já viu a introdução, evitando repetições indesejadas.
O conteúdo completo continua disponível a qualquer momento em
`COMO JOGAR` e `AJUDA`.

## Arquivos novos

- `scripts/tutorial/TutorialManager.gd`
- `scripts/ui/TutorialWindow.gd`

## Arquivos integrados

- `scripts/UIManager.gd`
- `scripts/ui/MainMenu.gd`

Todos os outros scripts e cenas permanecem iguais à Etapa 9.

## Roteiro de teste

1. Preserve a Etapa 9 como cópia de segurança.
2. Extraia este projeto em outra pasta.
3. Importe o novo `project.godot` no Godot 4.7.1.
4. Execute com `F5`.
5. No menu, clique em `COMO JOGAR`.
6. Avance e volte entre as sete etapas.
7. Confirme que cada etapa destaca a área correspondente.
8. Termine o guia e confirme que o menu reaparece.
9. Use `CONTINUAR` para verificar a compatibilidade do save.
10. Dentro da vila, clique em `AJUDA` e depois em
    `PULAR TUTORIAL`.
11. Troque uma profissão e confira a dica no registro.
12. Melhore uma construção e confira a dica na previsão.
13. Encerre um dia, resolva um acontecimento e confira a última dica.

Para testar a abertura automática, inicie uma `NOVA CAMPANHA` por
último. Essa ação continua apagando o slot anterior após a
confirmação. Se `COMO JOGAR` já tiver sido aberto nesta instalação,
o guia não será repetido automaticamente; use `AJUDA` para
reabri-lo.

## Resultado esperado

- o tutorial bloqueia cliques na vila enquanto está aberto;
- `Esc` equivale a pular o tutorial;
- fechar o guia vindo do menu retorna ao menu;
- fechar o guia vindo da vila retorna à vila;
- nenhuma ação do tutorial avança o dia ou altera recursos;
- o save anterior continua carregando normalmente;
- profissões, construções, acontecimentos, objetivos e reinício
  permanecem funcionando como na Etapa 9.
