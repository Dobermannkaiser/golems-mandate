# Golem's Mandate — Parte 3, Etapa 10 — v3.9.0

Base estável de origem: `v3.8.2`, validada no Godot pelo usuário. Esta entrega é uma candidata e não substitui a base até novo teste no motor.

## Relações entre NPCs

- Oito NPCs acompanhados: Mimo, Aelric, Kobi, Orion, Rubra, Brunna, Silas e Dália.
- Vinte e oito pares únicos, com dois diálogos por par.
- Cinquenta e seis diálogos obrigatórios em dias distintos, do dia 15 ao 118.
- Quatro respostas: apoiar A, apoiar B, permanecer neutro e conciliar.
- Apoio altera a amizade do jogador em `+20/−10`; conciliação aplica `+10/+10`.
- A conciliação exige amizade, recursos, Conselho completo ou memória da primeira conversa, conforme o assunto.
- Cinco estados internos: Conflito, Tensão, Neutro, Afinidade e Vínculo forte.
- A segunda conversa recorda a primeira; o resumo do dia seguinte apresenta um comentário posterior.
- O mapa mostra estado, causa descoberta e filtros para todos, afinidades e conflitos.
- Uma afinidade positiva descoberta concede no máximo `+1%` à produção total do Conselho. Conflitos não aplicam penalidade econômica.

## Persistência

- Save global: versão 18.
- Migração automática e determinística do save 17 da `v3.8.2`.
- Pontuação dos pares, diálogos resolvidos, memórias e diálogo obrigatório pendente são persistidos.
- Consequência e flag de resolução são aplicadas juntas; não há autosave entre escolha e reação final.

## Limite da validação

O Godot não estava disponível no ambiente de reconstrução. Verificações estruturais e de conteúdo foram executadas, mas a candidata depende do roteiro manual no motor.
