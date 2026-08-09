# Golem's Mandate — correção de diálogos v3.4.1

Esta revisão corrige falas que quebravam a imersão ao fazer personagens descreverem sistemas, recompensas ou elementos de interface que só o jogador deveria enxergar.

## Correções principais

- removida a frase “As três respostas têm consequências reais e visíveis na economia da vila” das falas dos representantes;
- o contexto objetivo dos assuntos do Conselho agora é apresentado pelo Narrador;
- o representante apresenta apenas sua avaliação pessoal e sua reação à decisão;
- duração, custos e modificadores continuam visíveis nas opções e nos painéis de previsão;
- removidas das falas as explicações sobre início/fim do projeto e ficha histórica;
- removida da resposta de subida de nível a explicação verbal da recompensa de +1 recurso;
- reescritas falas que usavam “nível máximo”, “esta etapa” ou outras referências externas ao mundo;
- falas de marco e de resultado foram ajustadas para soar como reação pessoal, não como relatório do sistema;
- premissas de eventos pessoais e reações narradas em terceira pessoa passaram a ser atribuídas ao Narrador, não ao retrato do NPC;
- o diálogo interno de diagnóstico de Mimo foi reescrito de forma diegética.

## O que permanece mecânico

Informações como custo imediato, duração, porcentagens e efeitos continuam nos textos dos botões, tooltips, previsão e notificações. Elas não são pronunciadas pelo personagem.

## Compatibilidade

- versão pública: 3.4.1;
- save permanece na versão 14;
- não exige campanha nova em relação à v3.4.0;
- nenhum cálculo econômico, passiva, sinergia ou retorno decrescente foi alterado.

## Validação realizada

- auditoria específica de imersão dos diálogos;
- regressões estruturais das Etapas 3, 4 e 5;
- verificação heurística de escopo local GDScript;
- simulações de progressão, oportunidades, passivas e sinergias;
- verificação de transparência dos retratos;
- extração limpa e nova verificação do ZIP final.

O Godot não foi baixado, instalado ou executado.
