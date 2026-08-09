# Golem’s Mandate — Parte 3, Etapa 2 — v3.1.0

## Situação desta versão

Esta é uma **versão candidata para validação**, construída sobre uma cópia da versão da Etapa 1 v3.0.0 que foi testada pelo usuário. A base anterior permanece separada e intacta.

A v3.1.0 implementa a Etapa 2 da Parte 3: **Construção por fila**.

Ela ainda não deve ser promovida a nova base estável antes do teste no Godot e da aprovação explícita do usuário.

## O que foi implementado

### Fila única de obras

Casas, construções fixas e melhorias usam a mesma fila e disputam os mesmos canteiros.

- o custo é pago integralmente ao colocar a obra na fila;
- obras que ainda não começaram podem ser reordenadas;
- obras ativas não podem ser pausadas nem reordenadas;
- uma construção fixa não pode ter duas melhorias pendentes ao mesmo tempo;
- a fila possui limite técnico seguro de 256 ordens.

### Capacidade de canteiros

A capacidade é calculada por:

```text
Canteiros simultâneos = 1 + parte inteira da população ÷ 20
```

Com limite máximo de quatro canteiros:

- 1–19 habitantes: 1 canteiro;
- 20–39 habitantes: 2 canteiros;
- 40–59 habitantes: 3 canteiros;
- 60 ou mais: 4 canteiros.

Se a população cair, obras ativas continuam. Nenhuma nova obra começa enquanto o número de obras ativas estiver acima ou igual à nova capacidade disponível.

### Tempos de trabalho

- Casa: 1 dia completo de trabalho;
- Construção fixa nível 1: 1 dia;
- Nível 2: 2 dias;
- Nível 3: 3 dias.

Uma obra solicitada no dia atual começa somente a partir do dia seguinte. Seu benefício entra em vigor no início do dia posterior ao último dia completo de trabalho.

Exemplos:

- casa solicitada no dia 10: trabalha no dia 11 e fica disponível no início do dia 12;
- nível 2 solicitado no dia 10: trabalha nos dias 11 e 12 e fica disponível no início do dia 13;
- nível 3 solicitado no dia 10: trabalha nos dias 11, 12 e 13 e fica disponível no início do dia 14.

### Avaliações

A avaliação do dia é resolvida antes de liberar uma obra concluída naquele mesmo dia.

Exemplo: uma obra cujo último dia de trabalho é o dia 20 só fica disponível no início do dia 21 e não conta para a avaliação do dia 20.

A janela de construções mostra o início previsto, o dia de disponibilidade e se a obra estará pronta a tempo da próxima avaliação.

### Cancelamento e reembolso

- obra na fila e ainda não iniciada: reembolso de 100%;
- obra ativa: reembolso de 50% e perda integral do progresso;
- obra com trabalho já concluído e aguardando liberação: não pode mais ser cancelada;
- cancelar libera o canteiro, mas uma substituta só começa na próxima resolução diária.

Toda tentativa de cancelamento passa por confirmação específica. O foco inicial fica em **MANTER OBRA**, a opção segura.

### Aparência da vila

Obras ativas agora possuem representação procedural reutilizável na vila:

- fundação;
- andaimes;
- travessas;
- materiais;
- indicador visual de progresso.

Os canteiros são desenhados por código e recortados pela área visual da vila, sem exigir um sprite exclusivo para cada estágio nesta etapa.

### Tutorial e Guia do Jogo

Foram atualizados para explicar:

- custo antecipado;
- fila única;
- capacidade por população;
- tempos de construção;
- reordenação;
- cancelamento e reembolso;
- conclusão após avaliações;
- previsão de disponibilidade.

### Save e migração

- `SAVE_VERSION = 9`;
- schema continua exclusivo da Parte 3: `golems_mandate_part3`;
- caminho continua `user://golems_mandate_part3_v3_save.json`;
- saves v8 da Etapa 1 podem ser migrados para v9;
- construções, população, recursos e progresso da campanha são preservados;
- a estrutura preparatória de fila da Etapa 1 não é convertida em obra real, porque ela não descontava recursos. A fila funcional começa vazia para evitar construções gratuitas.

### Oráculo de Diagnóstico

Foi adicionada uma checagem dedicada da fila, cobrindo:

- IDs e duplicatas;
- status;
- duração e progresso;
- custo pago;
- posições na fila;
- limite técnico;
- duplicidade de melhoria de prédio;
- capacidade por população;
- previsões;
- diferença legítima entre capacidade atual e obras já ativas após queda populacional.

A antiga verificação do nome do projeto foi removida completamente. Renomear a pasta ou o projeto para organização não gera aviso.

## O que não foi implementado nesta etapa

Continuam fora do escopo da v3.1.0:

- cartas visuais do Conselho;
- XP e níveis ativos;
- distribuição de atributos;
- passivas, sinergias e retornos decrescentes;
- variantes irreversíveis das construções;
- recrutamento de novas cartas;
- memória narrativa avançada;
- novos NPCs e cenas de relacionamento.

As estruturas preparatórias da Etapa 1 permanecem, mas esses sistemas continuam desativados.

## Validação realizada neste ambiente

Foram executadas validações estáticas, verificações de contratos, simulação de referência da fila, compilação das ferramentas Python, teste de integridade do pacote e comparação da simulação econômica anterior.

**O Godot não estava disponível neste ambiente.** Portanto, não houve execução real do projeto, teste visual dentro do motor, teste de foco em runtime, importação de recursos pelo editor nem validação auditiva.

A simulação econômica da v2.10.1/Etapa 1 produziu o mesmo relatório após as mudanças, indicando que as fórmulas econômicas antigas não foram alteradas. Isso **não prova** que o novo tempo de obras já está balanceado durante os 120 dias; essa consequência precisa de teste de campanha e será revisada nas etapas de simulação e balanceamento.

Consulte também:

- `AUDITORIA_FILA_DE_OBRAS_v3.1.0.txt`;
- `ROTEIRO_DE_TESTE_PARTE3_ETAPA2_v3.1.0.txt`;
- `VERIFICACAO_PARTE3_ETAPA2_v3.1.0.txt`;
- `SIMULACAO_FILA_DE_OBRAS_v3.1.0.txt`.
