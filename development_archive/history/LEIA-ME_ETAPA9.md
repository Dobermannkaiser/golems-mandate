# Square Village — Parte 2 — Etapa 9

## Música e efeitos — v2.9.2

Esta versão adiciona uma arquitetura completa de áudio sem alterar o formato do
save da Etapa 8.

### Gerenciador global

`AudioManager` cria e controla os canais `Music`, `Ambience`, `SFX` e `UI`, todos
enviados ao canal geral `Master`. O sistema cuida de transições, repetição,
variação de tom, limite de sons sobrepostos e redução de volume durante diálogos.

### Música

- menu principal;
- duas variações de primavera;
- verão;
- outono;
- duas variações de inverno;
- história e auditorias;
- acontecimentos cômicos.

A troca de estação usa transição suave. As variações disponíveis são escolhidas
sem trocar a faixa toda vez que a interface atualiza.

### Ambientes

O ambiente genérico enviado foi convertido em quatro versões sazonais. Pequenos
sons ocasionais de martelo, madeira, poço e pássaros podem surgir em intervalos
aleatórios enquanto a vila está ativa.

### Efeitos

Há efeitos para interface, construções, profissões, Conselho, encerramento do
dia, save, carregamento, acontecimentos, avaliações, vitória, derrota,
relacionamentos, capítulos, recrutamento e avisos de recursos.

O efeito de recompensa enviado foi recortado para remover o atraso inicial de
aproximadamente 3,24 segundos.

### Configurações

A tela de configurações possui controles separados para:

- Volume Geral;
- Música;
- Ambiente;
- Efeitos;
- Interface.

Cada canal possui botão de teste. Também existem `SILENCIAR TUDO` e
`RESTAURAR ÁUDIO`. Configurações antigas de volume geral são convertidas
automaticamente.

### Compatibilidade

O save da campanha continua no esquema v6 e permanece compatível com a v2.8.3.
As preferências de áudio são globais e ficam no arquivo de configurações do
usuário, separadas da campanha.
