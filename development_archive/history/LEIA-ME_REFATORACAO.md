# Square Village — segunda refatoração

Esta cópia preserva o funcionamento da etapa 5 e separa o sistema de
acontecimentos e os cartões dos habitantes em componentes próprios.

## Como abrir

1. Mantenha sua pasta anterior como cópia de segurança.
2. Extraia a pasta do projeto.
3. No Godot, use **Importar** e selecione o `project.godot` desta pasta.
4. Abra o projeto e execute com `F5`.

Não é necessário copiar scripts individualmente nem alterar a árvore da cena.

## Nova organização

- `scripts/GameManager.gd`: recursos, moradores e passagem dos dias.
- `scripts/UIManager.gd`: interface geral e coordenação da seleção.
- `scripts/events/EventCatalog.gd`: os 12 acontecimentos e suas 36 escolhas.
- `scripts/events/EventManager.gd`: sorteio, probabilidades, custos e resultados.
- `scripts/ui/EventWindow.gd`: janela visual dos acontecimentos.
- `scripts/ui/VillagerCard.gd`: conteúdo, tooltips e animações dos cartões.
- `scenes/ui/villager_card.tscn`: componente reutilizável de cartão.

As cenas, atributos, profissões, fórmulas diárias e consequências dos
acontecimentos foram preservados.

## Teste recomendado

1. Clique em cada cartão e confirme o destaque do cartão e do quadrado.
2. Passe o mouse pelos atributos e profissões para conferir os tooltips.
3. Troque as profissões e confira previsão, texto e animações.
4. Encerre o dia 1 e confirme que a janela de acontecimento aparece.
5. Troque o habitante responsável e observe a chance mudar.
6. Resolva a escolha e avance até pelo menos o dia 3.

Se o Godot mostrar algum erro, envie uma captura do painel **Saída** com a
primeira linha vermelha visível.
