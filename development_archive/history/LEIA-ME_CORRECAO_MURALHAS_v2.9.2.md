# Square Village — Muralhas procedurais v2.9.2

A muralha da vila não utiliza mais as imagens `wall_line.png`, `wall_corner.png` e `wall_gate.png`.

## Novo desenho
- nível 1: paliçada de madeira;
- nível 2: muralha de pedra com torres;
- nível 3: muralha fortificada com portão central;
- pedras, juntas, merlões, torres e grades são desenhados pelo Godot;
- a escala é calculada separadamente para a vila normal e ampliada;
- o ícone da construção também é gerado em tempo de execução.

A alteração elimina encaixes entre sprites e impede sobreposições causadas pelas proporções dos PNGs antigos.
