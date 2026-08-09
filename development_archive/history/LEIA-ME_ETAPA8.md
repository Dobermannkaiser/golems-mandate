# Square Village — Etapa 8

## Salvamento e carregamento

Esta versão adiciona um slot de campanha versionado, carregamento manual e
salvamento automático protegido.

O save preserva:

- dia, alimentação, material e felicidade;
- nomes, atributos e profissões dos quatro habitantes;
- níveis das cinco construções;
- progresso, crises, vitória ou derrota da campanha;
- acontecimentos já utilizados;
- dias sem acontecimento;
- acontecimento pendente e o dia que ele concluiu.

## Como o autosave funciona

Ao abrir o projeto, o jogo não sobrescreve um save antigo automaticamente.

1. Clique em `SALVAR / CARREGAR`.
2. Clique em `SALVAR AGORA` ou carregue uma campanha existente.
3. O botão mudará para `SALVO / AUTOMÁTICO`.
4. A partir desse momento, o mesmo slot será atualizado depois de:
   - mudar uma profissão;
   - melhorar uma construção;
   - encerrar um dia;
   - iniciar ou resolver um acontecimento;
   - concluir a campanha.

Ao usar `NOVA CAMPANHA`, o slot anterior é apagado para que uma partida
encerrada não reapareça como continuação da nova vila.

## Roteiro principal de teste

1. Execute o projeto com `F5`.
2. Distribua profissões e melhore o Poço para o nível 1.
3. Abra `SALVAR / CARREGAR`.
4. Clique em `SALVAR AGORA`.
5. Confirme que aparece `AUTOSAVE ATIVO`.
6. Encerre o dia 1 e deixe o acontecimento aberto.
7. Pare o jogo com `F8`.
8. Execute novamente com `F5`.
9. Abra `SALVAR / CARREGAR`.
10. Confirme que o slot mostra o dia 2 e um acontecimento pendente.
11. Clique em `CARREGAR` e depois em `CONFIRMAR`.
12. Confirme que o mesmo acontecimento reaparece.
13. Confira nomes, atributos, profissões, recursos e nível do Poço.
14. Resolva o acontecimento e avance mais dois dias.
15. Feche e abra o jogo novamente.
16. Carregue o slot e confirme o novo progresso.

## Testes adicionais

- Tente carregar e cancele antes do segundo clique.
- Tente excluir e cancele antes do segundo clique.
- Exclua o save, confirme que `CARREGAR` fica desativado e salve novamente.
- Carregue uma campanha finalizada e confirme que a tela de resultado reaparece.
- Inicie `NOVA CAMPANHA` e confirme que o slot anterior foi removido.

## Estrutura nova

- `scripts/save/SaveManager.gd`: leitura, escrita, versão e validação.
- `scripts/ui/SaveWindow.gd`: janela medieval de salvar e carregar.

Os outros sistemas apenas expõem e restauram seu próprio estado. As regras de
produção, acontecimentos, campanha e construções continuam iguais à Etapa 7.
