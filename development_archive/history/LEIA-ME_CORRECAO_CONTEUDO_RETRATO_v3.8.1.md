# Golem's Mandate — correção da Parte 3, Etapa 9 — v3.8.1

Esta candidata corrige dois problemas encontrados no teste da `v3.8.0`. A base estável `v3.7.0` e o pacote anterior permanecem preservados.

## Conteúdo de Dália

- O assunto `dalia_corpo` foi removido integralmente.
- Em seu lugar, `dalia_compostagem` apresenta uma situação leve sobre adubo, calor e organização comunitária.
- A biografia de Dália agora se concentra em sementes, remédios, histórias, curiosidade e cuidado coletivo.
- Os textos de Dália não mencionam peso, corpo ou características físicas sensíveis.
- A auditoria da Etapa 9 passou a impedir a reintrodução acidental desse tipo de conteúdo na rota da personagem.

## Retratos

O PNG de Dália já estava correto. A aparência apagada era causada por filtros de cor aplicados pela janela de diálogo para simular expressões.

- Retratos PNG agora são exibidos com suas cores originais.
- Nenhuma imagem foi gerada, redesenhada ou substituída.
- O suporte a arquivos próprios para expressões permanece no catálogo; quando houver arte específica, ela poderá ser usada sem recolorir o retrato.

## Compatibilidade

- Versão pública: `3.8.1`.
- Save global permanece na versão `17`.
- Não há migração nova nem mudança no estado persistido.
- Saves da `v3.8.0` continuam compatíveis.

## Limite de validação

O Godot não está instalado neste ambiente. As verificações estáticas, de conteúdo, referências, escopo e transparência passaram, mas a confirmação visual final deve ser feita no motor.
