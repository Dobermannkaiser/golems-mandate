# SquareVillage — Parte 2, Etapa 1

## Fundação da expansão

Esta versão foi criada a partir de
`SquareVillage-Polido-Otimizado`, que permanece como a base estável
e encerrada da Parte 1.

A Etapa 1 prepara os dados que sustentarão a campanha longa,
população, moradia, especialistas, narrativa e relacionamentos.
Ela não antecipa as mudanças visuais ou de balanceamento das
próximas etapas.

## Decisões aplicadas

- Campanha planejada para 120 dias.
- Quatro estações com 30 dias cada.
- Checkpoints nos dias 20, 40, 60, 80, 100 e 120.
- Modo livre preparado para ser liberado após o dia 120.
- População estrutural inicial de 8 habitantes.
- Capacidade habitacional inicial de 10.
- Quatro representantes ativos no conselho.
- Perfil básico do jogador como Prefeito e Golem de Pedregulho.
- NPCs futuros sem nomes, espécies ou personalidades definitivas.
- Relacionamentos de 1 a 10 para amizade.
- Relacionamentos com opção romântica podem avançar até 15.

## Catálogo da campanha

O arquivo `scripts/campaign/CampaignCatalog.gd` contém:

- duração total;
- estações e suas faixas de dias;
- checkpoints;
- quatro metas em cada checkpoint:
  alimentação, material, felicidade e população;
- espaços para acontecimento principal e NPC de cada capítulo;
- configuração do modo livre.

As 24 metas numéricas estão presentes com valor provisório e
marcadas como `provisional`. Elas não são usadas pelo gameplay nesta
etapa. Os valores reais serão definidos depois das simulações de
economia.

## Novo salvamento

A Parte 2 usa:

`user://square_village_part2_save.json`

O save da Parte 1 usa outro caminho e permanece preservado. Não há
conversão automática nem leitura do arquivo antigo.

O novo formato usa a versão 2 e o identificador
`square_village_part2`. O estado da campanha está separado nas
seguintes seções:

1. `player_profile`
2. `calendar`
3. `resources`
4. `population`
5. `council`
6. `npcs`
7. `relationships`
8. `buildings`
9. `events`
10. `campaign`
11. `narrative`
12. `runtime`

O carregamento rejeita arquivos com versão, identificador, seções,
calendário, conselho, NPCs ou relacionamentos incompatíveis.

As configurações gerais continuam compartilhadas com a Parte 1.

## Modelos preparados

### Perfil do jogador

Guarda nome, pronomes, título e forma do golem. A tela de
personalização será criada somente quando for necessária.

### População

Guarda população total, capacidade habitacional, vagas disponíveis
e estado de superlotação. Nesta etapa, os valores ainda não alteram
produção ou consumo.

### Conselho

Os quatro habitantes atuais receberam identificadores internos
estáveis:

- `representante_01`
- `representante_02`
- `representante_03`
- `representante_04`

Seus nomes e atributos continuam sendo gerados como antes. Não são
personagens definitivos.

### NPC

O modelo aceita identidade, espécie, profissão, passiva, conjunto de
retratos, checkpoint de chegada e disponibilidade de romance.
Nenhum NPC definitivo foi criado nesta etapa.

### Relacionamento

Todo relacionamento começa em 1.

- Personagem sem romance: máximo 10.
- Personagem com romance disponível: máximo 15.
- Valores de 1 a 10 representam amizade.
- Valores de 11 a 15 representam interesse romântico.

O sistema impede que um relacionamento ultrapasse o limite permitido
para aquele personagem.

## O que permanece igual nesta versão

- Interface e aparência.
- Quatro cartões atuais.
- Fórmulas de produção e consumo.
- Acontecimentos existentes.
- Construções existentes.
- Tutorial.
- Campanha jogável de 20 dias da Parte 1.

O catálogo de 120 dias já existe, mas só substituirá a campanha
visível na Parte 2 — Etapa 2. Essa separação permite testar primeiro
a segurança do novo save sem misturar erros de calendário e
balanceamento.

## Roteiro de teste

1. Extraia esta versão em uma pasta própria.
2. Importe o arquivo `project.godot` no Godot 4.7.1.
3. Execute com `F5`.
4. Confirme que o menu não oferece o save antigo da Parte 1.
5. Inicie uma nova campanha.
6. Confira que a interface e os quatro habitantes funcionam como na
   versão polida.
7. Altere profissões, avance um dia e salve.
8. Abra `MENU`, use `CARREGAR` e confira os detalhes.
9. Carregue a campanha e confirme dia, recursos, profissões,
   construções e acontecimentos.
10. Feche o jogo, execute novamente e use `CONTINUAR`.
11. Altere uma configuração, feche e abra novamente para confirmar
    que ela continua persistente.
12. Abra a Parte 1 separadamente e confirme que o save antigo dela
    continua disponível.

Durante os testes, o rótulo visual de população continua mostrando os
quatro habitantes da Parte 1. A população estrutural de 8 será ligada
à interface e à economia na Etapa 3.

## Próxima etapa

**Parte 2 — Etapa 2: Campanha de 120 dias e estações**

Ela conectará o catálogo preparado nesta versão ao gameplay:

- calendário completo;
- indicador de estação;
- seis avaliações;
- modificadores sazonais;
- conclusão no dia 120;
- modo livre.
