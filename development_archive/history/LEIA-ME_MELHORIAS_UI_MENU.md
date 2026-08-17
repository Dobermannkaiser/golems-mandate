# Golem's Mandate — melhorias de UI no menu principal

## Base e escopo
- Origem: v3.11.5 + otimização do índice de habitantes já testada.
- Arquivos alterados: `scripts/MedievalTheme.gd` e `scripts/ui/MainMenu.gd`.
- Godot não foi executado por mim; validação de runtime depende do teste manual.

## O que mudou

### 1. Contraste do botão desabilitado (afeta TODO botão do jogo)
`MedievalTheme.gd`: o estilo `disabled` de qualquer `Button` agora usa a cor
mais escura da paleta (`panel_dark`) em vez de uma variação sutil da cor do
próprio botão, e o texto desabilitado passou a usar um cinza dessaturado
(antes era um tom quase idêntico ao texto ativo). Resultado esperado: um
botão desabilitado deve "recuar" visualmente e não parecer clicável — isso
vale pra qualquer tela do jogo, não só o menu.

### 2. Hierarquia visual no menu principal (só nesta tela)
`MainMenu.gd`: o botão que representa a ação principal do momento
(CONTINUAR / VOLTAR À VILA / NOVA CAMPANHA — dependendo do estado) agora
ganha destaque dourado. SAIR DO JOGO ficou com um estilo discreto (contorno
fino, sem preenchimento). A troca de qual botão é "primário" acontece
automaticamente conforme o estado do save, dentro de `_refresh_main_page()`.
Não mexe no tema global — só nesses botões específicos do menu.

### 3. Navegação por teclado/gamepad explícita no menu principal
Os 6 botões (Continuar, Nova Campanha, Carregar, Guia, Configurações, Sair)
agora têm `focus_neighbor_top`/`focus_neighbor_bottom` fixados
explicitamente, em ordem, com wrap (do último volta pro primeiro). Antes
dependia do cálculo automático de posição espacial do Godot, que costuma
funcionar mas não é garantido.

### Item 4 (fatiar UIManager/reestruturar UI em cenas): não alterado, por decisão conjunta.

## Teste recomendado
1. Abrir o projeto, deixar recompilar sem erros novos.
2. **Sem save**: confirmar que NOVA CAMPANHA aparece destacada em dourado, e
   CONTINUAR/CARREGAR aparecem visivelmente "apagados" (não mais parecidos
   com os botões ativos).
3. Iniciar uma campanha, salvar, voltar ao menu principal: confirmar que
   agora é CONTINUAR que fica destacado, e NOVA CAMPANHA volta ao estilo
   normal.
4. Abrir o menu de dentro do jogo (pausa): confirmar que VOLTAR À VILA fica
   destacado.
5. Testar navegação só com teclado (setas + Enter) e, se tiver controle
   conectado, também com gamepad: confirmar que dá pra percorrer os 6
   botões em ordem, incluindo voltar do primeiro pro último (wrap).
6. Testar em qualquer outra tela com botão desabilitado (ex: abrir
   Recrutamento sem candidato disponível) pra confirmar que o contraste
   também melhorou lá — é o mesmo estilo global.
