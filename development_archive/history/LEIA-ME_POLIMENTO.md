# SquareVillage — polimento e otimização

Esta versão parte diretamente da Etapa 10 testada. O objetivo do passe foi
reduzir repetição e trabalho desnecessário sem alterar jogabilidade, equilíbrio,
textos, aparência aprovada ou compatibilidade do salvamento.

## O que foi otimizado

- A criação repetida de rótulos e estilos de painel foi centralizada em
  `MedievalTheme.gd`.
- Construções e acontecimentos agora possuem índices internos por identificador.
- Os efeitos ativos das construções são recalculados somente quando um nível muda.
- Consultas de resumo do save reutilizam a última leitura validada; um carregamento
  explícito continua lendo e validando o arquivo real.
- Pedidos repetidos de reposicionamento da vila e dos marcadores são agrupados.
- `UIManager.gd` guarda as referências do fundo e do terreno, evitando buscas
  recursivas repetidas na cena.
- Os marcadores de construções guardam referências diretas aos rótulos de nome e
  nível, eliminando dependência de caminhos internos de nós.

## O que permaneceu igual

- fórmulas de produção, consumo e felicidade;
- 20 dias, condições de vitória e derrota;
- 12 acontecimentos e 36 escolhas;
- 5 construções e 15 melhorias;
- custos, benefícios e probabilidades;
- formato e versão do save;
- menu, configurações e tutorial;
- cenas e aparência visual.

## Roteiro curto de teste

1. Importe o `project.godot` no Godot 4.7.1 e execute com `F5`.
2. Abra `COMO JOGAR` e percorra algumas etapas do tutorial.
3. Continue uma campanha salva e confira habitantes, profissões e construções.
4. Troque uma profissão e confirme a atualização imediata da previsão.
5. Melhore uma construção e confirme custo, benefício, nome e nível na vila.
6. Salve, feche a execução, abra novamente e use `CONTINUAR`.
7. Encerre um dia, resolva um acontecimento e confirme que o depurador permanece
   sem erros.

O pacote foi verificado estruturalmente, mas a execução final deve ser confirmada
no Godot instalado no computador do jogador.
