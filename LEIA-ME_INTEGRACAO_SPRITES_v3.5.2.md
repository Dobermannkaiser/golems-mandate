# Golem's Mandate — Parte 3, Etapa 6 — v3.5.2

## Objetivo desta revisão

Esta revisão integra as dez artes finais enviadas pelo usuário para as builds de nível 3 das construções. Ela foi criada sobre a v3.5.1 otimizada e mantém as regras, efeitos, diálogos, acontecimentos e formato de save da Etapa 6.

## Artes integradas

- Silo de Reserva
- Cozinha Comunitária
- Serraria Intensiva
- Oficina de Carpintaria
- Reservatório Profundo
- Fonte Comunitária
- Mercado Comunitário
- Jardim Público
- Bastião de Pedra
- Portões Vigilantes

## Tratamento aplicado aos arquivos recebidos

O ZIP recebido continha dez imagens JPEG RGB de 352 × 240 pixels, embora o pedido original previsse PNG. Para manter a transparência necessária no Godot, as imagens foram:

1. associadas às dez builds corretas;
2. convertidas para PNG RGBA;
3. tratadas para remover o fundo preto conectado às bordas;
4. mantidas em 352 × 240 pixels;
5. salvas nos mesmos caminhos já usados pelo catálogo e pela vila.

Nenhum efeito, valor econômico ou regra de construção foi alterado.

## Compatibilidade

- versão pública: `3.5.2`;
- versão do save: `15`;
- não exige campanha nova em relação à v3.5.0 ou v3.5.1;
- a confirmação final depende do teste no Godot pelo usuário.

## Limites da validação

O Godot não foi baixado, instalado ou executado. Foram realizados somente verificadores estáticos, inspeção dos arquivos de imagem, validação de referências, dimensões, transparência e integridade do ZIP.
