# Correção de camadas — v2.5.4

## Problema corrigido

Os sprites da vila recebiam valores de `z_index` baseados diretamente na posição vertical. Alguns conselheiros ultrapassavam `z_index 500`, enquanto as janelas de menu e construções usavam valores entre 100 e 300. Por isso casas e moradores eram desenhados acima dos modais.

## Alterações

- A raiz da visualização da vila usa `z_index = 0`.
- Construções usam profundidade local entre 0 e 18.
- Moradores e conselheiros usam uma camada local limitada, com valor global máximo 55 na mini-vila.
- Todas as janelas modais permanecem acima da vila; a primeira começa em 100.
- `clip_contents` foi ativado no quadro da vila e nas camadas internas.
- As camadas internas agora ocupam todo o painel, evitando recorte incorreto.
- A ordenação pela posição vertical foi preservada, mas normalizada para uma faixa segura.

## Teste recomendado

1. Abra o jogo e permaneça no menu principal.
2. Confirme que nenhum gato, casa ou prédio aparece por cima do menu.
3. Inicie uma campanha.
4. Abra Construções, Objetivos, Salvar/Carregar, Ajuda e Menu.
5. Confirme que todos os sprites ficam atrás das janelas.
6. Abra a vila ampliada e depois uma construção a partir dela.
7. Confirme que a vila ampliada fecha antes da janela de construções aparecer.
