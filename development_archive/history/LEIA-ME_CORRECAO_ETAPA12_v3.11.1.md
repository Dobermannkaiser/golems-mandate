# Golem's Mandate — correção da Etapa 12 — v3.11.1

Esta candidata corrige a falha de execução observada ao abrir a tela **Avaliação** na `v3.11.0` e elimina os seis avisos de compilação relatados pelo usuário. Nenhuma mecânica, conteúdo ou schema de save foi alterado.

## Erro de execução corrigido

A tela tentava construir uma `String` diretamente a partir do valor decimal atual de uma meta, por exemplo `48.0`. No Godot 4.7, essa chamada era inválida e encerrava o jogo ao reconstruir as linhas da avaliação.

Os valores agora passam por um formatador de apresentação explícito:

- recursos em `float`: uma casa decimal;
- população em `int`: número inteiro;
- texto já formatado: preservado por `str()`.

O mesmo caminho seguro é usado para valor atual, projeção e meta.

## Avisos eliminados

- `seed` foi renomeado para não sombrear a função global interna.
- as chaves de efeito de variante e de construção receberam nomes distintos;
- o ID de candidato foi diferenciado do ID do representante escolhido;
- o parâmetro intencionalmente não utilizado de `VillagerCard.set_selected()` recebeu prefixo `_`;
- as variáveis residuais `met_goals` e `total_goals` foram removidas.

## Persistência e escopo

- envelope global de save permanece na versão `18`;
- nenhuma migração foi criada;
- nenhum valor de balanceamento foi alterado;
- nenhum asset, diálogo, relação, construção ou acontecimento foi alterado;
- a `v3.11.0` foi preservada e a correção foi montada em cópia separada.

## Limitação

O Godot não foi executado. A abertura real da tela, a recompilação sem avisos e a continuidade do jogo dependem do teste manual no motor.
