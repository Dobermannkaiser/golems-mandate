# Square Village — Parte 2, Etapa 5 — revisão v2.5.2

Esta revisão parte da v2.5.1 funcional e não altera economia, campanha, população, conselho ou formato de save.

## Correções visuais

- remoção do fundo preto dos quatro sprites de moradores;
- escalas próprias para a mini-vila e para a vila ampliada;
- casas menores e distribuídas em lotes sem cobrir os prédios;
- prédios redimensionados por categoria, sem depender do tamanho original do arquivo;
- remoção da camada escura que ficava sobre construções prontas;
- terrenos vazios substituídos por fundações discretas, sem textos repetidos;
- novo chão sazonal de alta resolução, sem repetição evidente de tiles;
- caminhos mais finos na mini-vila e mais legíveis na visão ampliada;
- nomes dos conselheiros ocultos na mini-vila, exceto o selecionado;
- detalhes sazonais reduzidos para evitar poluição visual;
- crescimento da população representado por moradores, árvores e uma pequena barraca comunitária.

## Otimizações

- moradores comuns conservam o mesmo sprite em vez de serem sorteados a cada atualização;
- moradores são recriados somente quando a população visual muda;
- casas só são recalculadas quando moradia, população ou modo de visualização mudam;
- seleção de conselheiro não reinicia a movimentação de todos os habitantes;
- animações da vila ampliada são pausadas quando a janela está fechada;
- os quadrados antigos continuam como modelos de dados, mas o nó visual legado inteiro fica oculto;
- o layout antigo dos quadrados deixou de ser recalculado.

## Compatibilidade

- versão do projeto: 2.5.2;
- save permanece na versão 4;
- saves usados pela v2.4.3 e v2.5.1 continuam compatíveis.
