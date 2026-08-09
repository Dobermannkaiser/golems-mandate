# Square Village — Etapa 7

## Construções e melhorias da vila

Esta versão acrescenta cinco construções com três níveis cada.
As melhorias são permanentes durante a campanha atual e são
reiniciadas ao escolher **NOVA CAMPANHA**.

## Construções

| Construção | Nível 1 | Nível 2 | Nível 3 |
|---|---:|---:|---:|
| Celeiro | 6 materiais / +10% alimentação | 11 materiais / +22% alimentação | 18 materiais / +35% alimentação |
| Serraria | 8 materiais / +12% material | 13 materiais / +25% material | 20 materiais / +40% material |
| Poço | 5 materiais / -10% desgaste de felicidade | 10 materiais / -22% desgaste de felicidade | 16 materiais / -35% desgaste de felicidade |
| Praça | 7 materiais / +0,6 felicidade ao dia | 12 materiais / +1,3 felicidade ao dia | 18 materiais / +2,1 felicidade ao dia |
| Muralha | 9 materiais / -12% manutenção | 15 materiais / -25% manutenção | 22 materiais / -40% manutenção |

Os valores de cada nível são cumulativos finais. Por exemplo, o
Celeiro no nível 2 fornece +22%, não +10% e +22%.

## Como abrir no Godot

1. Preserve a versão da Etapa 6 como cópia de segurança.
2. Extraia o arquivo compactado da Etapa 7 em uma pasta nova.
3. Abra o Godot 4.7.1.
4. Na tela do Project Manager, clique em **Import**.
5. Selecione o `project.godot` da pasta extraída.
6. Execute o projeto com `F5`.

## Roteiro de teste

1. No dia 1, clique em **CONSTRUÇÕES**.
2. Melhore o **Poço** para o nível 1.
3. Confirme que:
   - o material cai de 10 para 5;
   - o contador muda para `1 / 15`;
   - o Poço aparece como nível 1 na área da vila;
   - a previsão de felicidade passa a usar a redução de 10%.
4. Volte à janela de construções e confirme que opções sem material
   suficiente ficam desativadas com a explicação no tooltip.
5. Escolha profissões, encerre o dia 1 e resolva o acontecimento.
6. Avance alguns dias, produza mais material e faça outra melhoria.
7. Teste Celeiro ou Serraria e confira a produção individual no
   tooltip da profissão de um habitante.
8. Teste Praça ou Muralha e confira a previsão do próximo dia.
9. Continue a campanha para confirmar que acontecimentos, vitória,
   derrota e observação da vila continuam funcionando.
10. Escolha **NOVA CAMPANHA** e confirme que o contador volta para
    `0 / 15` e todos os terrenos retornam ao nível 0.

## Organização técnica

- `scripts/buildings/BuildingCatalog.gd`: dados, custos e benefícios;
- `scripts/buildings/BuildingManager.gd`: níveis, compra e efeitos;
- `scripts/ui/BuildingWindow.gd`: janela de construções;
- `scripts/ui/BuildingVisuals.gd`: evolução visual na área da vila;
- `scripts/GameManager.gd`: integração com produção, custos e campanha;
- `scripts/UIManager.gd`: coordenação da interface;
- `scripts/ui/VillagerCard.gd`: atualização da previsão individual.

As cenas, os 12 acontecimentos, as 36 escolhas, as profissões e as
condições de vitória e derrota da Etapa 6 foram preservadas.
