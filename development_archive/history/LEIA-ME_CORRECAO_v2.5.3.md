# Square Village — correção v2.5.4

Esta versão corrige o erro de parser apresentado no Godot 4.7.1:

- a função auxiliar `draw_ellipse()` foi renomeada para `_draw_ellipse_shape()`;
- a chamada correspondente também foi atualizada;
- nenhuma regra de jogo, save, população, Conselho ou construção foi alterada;
- o verificador da Etapa 5 agora reprova funções auxiliares públicas com prefixo `draw_*`, evitando novos conflitos com métodos nativos de `CanvasItem`.

Extraia esta versão em uma pasta nova. O save permanece na versão 4 e compatível com a base anterior.
