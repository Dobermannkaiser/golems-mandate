# Square Village — Parte 2 — Etapa 9

## Música e efeitos — v2.9.2

A versão v2.9.2 adiciona o sistema completo de áudio ao projeto, preservando a
campanha, os relacionamentos e os saves compatíveis da v2.8.3.

## Conteúdo principal

- gerenciador global de áudio por autoload;
- canais separados para volume geral, música, ambiente, efeitos e interface;
- música própria para menu, primavera, verão, outono e inverno;
- duas variações para primavera e inverno;
- músicas especiais para história e acontecimentos cômicos;
- ambiente sazonal contínuo e sons ocasionais da vila;
- transições suaves entre músicas e ambientes;
- redução automática do áudio durante diálogos e menus sobrepostos;
- efeitos de interface, gestão, acontecimentos, relacionamentos e história;
- atenuação do volume quando a janela perde o foco;
- configuração global persistente e independente do save da campanha.

## Áudio fornecido e tratamento

As faixas enviadas pelo usuário foram convertidas para OGG Vorbis, organizadas
por estação e normalizadas. O efeito de recompensa teve aproximadamente 3,24
segundos de silêncio inicial removidos, passando a tocar imediatamente.

Os efeitos curtos ausentes foram criados proceduralmente para o projeto, sem
amostras externas, e armazenados em WAV PCM.

## Compatibilidade

O esquema de campanha permanece em v6. Saves válidos da v2.8.3 podem ser
carregados normalmente. As novas preferências de áudio são migradas a partir da
configuração geral de volume anterior.

## Testes recomendados

Consulte `ROTEIRO_DE_TESTE_ETAPA9_v2.9.2.txt`. O relatório estrutural está em
`VERIFICACAO_ETAPA9_v2.9.2.txt`, e a análise dos arquivos de som está em
`AUDITORIA_AUDIO_ETAPA9_v2.9.2.txt`.

## Correção v2.9.2 — muralhas procedurais

As imagens antigas da muralha foram removidas. A vila agora desenha paliçada,
torres, pedras, merlões e portão diretamente no `BuildingVisuals.gd`, incluindo
uma miniatura procedural na interface de construções. Consulte
`AUDITORIA_MURALHAS_PROCEDURAIS_v2.9.2.txt` e
`PREVIA_MURALHAS_PROCEDURAIS_v2.9.2.png`.
