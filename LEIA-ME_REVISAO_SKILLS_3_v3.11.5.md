# Golem's Mandate — Parte 3, Etapa 12 — v3.11.5

Revisão corretiva da `v3.11.4` orientada pelas skills **Godot — Programação
para Jogos 3.0** e **Godot — UX e UI para Jogos 3.0**.

## Base e escopo

- Origem: `GolemsMandate-Parte3-Etapa12-v3.11.4.zip`.
- A `v3.11.4` foi preservada sem alterações.
- A base estável continua sendo a `v3.10.1` até aprovação do usuário.
- Godot não foi executado.
- Nenhuma simulação extensa foi executada.

## Correções

### Recrutamento

- Cada avaliação aprovada nos dias 20, 40, 60, 80, 100 e 120 garante uma
  escolha entre duas cartas.
- Pontos de relacionamento continuam escolhendo a origem e a espécie, mas não
  bloqueiam mais a oferta.
- Empates entre espécies continuam sendo decididos pelo jogador.
- Pendências são preservadas e apresentadas em sequência; uma vaga antiga não
  bloqueia as seguintes.
- Ofertas já materializadas continuam persistidas e não são rerroladas no load.
- O estado interno do recrutamento passou de `2` para `3`; estados `1` e `2`
  continuam aceitos e são reconciliados sem alterar o envelope global do save.
- O Conselho agora distingue escolhas concluídas, pendentes e futuras.

### Save e recuperação

- O save continua no envelope `18` e no mesmo caminho da Parte 3.
- O envelope passa a registrar também a versão pública do projeto.
- Quando o principal está ausente, vazio, corrompido ou estruturalmente
  inválido, o jogo tenta o `.bak` já criado pelo sistema.
- Um save de versão futura continua recusado e não é substituído por backup
  antigo.
- Depois de recuperar um backup, o próximo save restaura o principal sem
  destruir o backup válido.
- Menu e tela de Save informam quando a recuperação ocorreu.

### Identidade e determinismo

- Configurações, Tutorial e Histórico passam a usar arquivos
  `golems_mandate_*`.
- Os três arquivos antigos `square_village_*` continuam legíveis e são
  migrados sem serem apagados.
- O Histórico usa escrita temporária, restaura o caminho canônico a partir de
  backup/arquivo legado e preserva uma cópia válida se o principal corromper.
- O metadado interno dos sons de botão usa a identidade oficial.
- O placeholder visual `Quadrado` foi substituído por `Habitante`.
- Os quatro fundadores não recebem mais nomes aleatórios transitórios antes da
  geração oficial baseada na semente da campanha.

## Compatibilidade

- Saves da `v3.11.4` continuam compatíveis.
- Recursos, metas, inverno, população, economia, construções, narrativa,
  relações e retratos não foram rebalanceados nesta revisão.
- Uma campanha antiga com recrutamentos bloqueados recupera as escolhas
  pendentes ao carregar. A recuperação não concede cartas automaticamente: o
  jogador ainda escolhe uma candidata por oferta.

## Limites da validação

As verificações executadas são estruturais, contratuais e matemáticas curtas.
Elas não substituem importação, compilação, warnings, abertura das telas,
input, foco, áudio e runtime no Godot real.
