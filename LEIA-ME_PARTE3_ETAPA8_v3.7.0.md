# Golem's Mandate — Parte 3, Etapa 8 — v3.7.0

## Status

Esta entrega é uma **candidata para teste no Godot**. Ela foi construída sobre a v3.6.0 e não substitui a última versão estável até que o roteiro manual seja concluído e aprovado.

## Memória e acontecimentos encadeados

A Etapa 8 acrescenta quatro histórias pessoais, uma para cada fundador procedural:

- Reconhecimento;
- Responsabilidade;
- Pertencimento;
- Convicções.

Cada cadeia possui dois acontecimentos. A história é atribuída uma única vez ao fundador mais compatível segundo atributos, personalidade e passiva, sem repetir fundador. A primeira conversa registra uma decisão; a segunda só aparece quando uma condição real do mundo surge nos dez dias concluídos seguintes.

As condições observam participação no Conselho, pressão sobre alimentação/material/felicidade, mudança da composição ativa e avanço ou especialização de construções. Estação, obras e Conselho alteram o texto das cenas. Outros fundadores podem reagir, mas o protagonista da cadeia mantém o foco.

Se a condição não surgir dentro da janela, a cadeia expira silenciosamente. A decisão inicial continua na Ficha Histórica, mas não há custo, recompensa nem mensagem artificial de oportunidade perdida.

## Consequências e comunicação

As consequências podem ser relevantes, porém permanecem recuperáveis. O resultado tardio cita naturalmente a decisão anterior, e a Ficha Histórica registra abertura e retorno. O fundador correto recebe o histórico e os 20 pontos de experiência do acontecimento, mesmo quando está na reserva.

Quatro escolhas marcantes podem deixar vestígios visuais persistentes na vila: Estandarte dos Fundadores, Marco da Reparação, Banco Compartilhado e Lanterna do Conselho. São desenhos nativos do projeto, salvos junto da campanha e aplicados apenas uma vez.

## Repetição e persistência

O gerenciador de acontecimentos mantém os cinco IDs mais recentes e prefere outra opção disponível. Estados das cadeias, escolha inicial, prazo, condição-base, acontecimento ativo, definições dinâmicas e vestígios visuais são persistidos.

O formato de save passou para a versão 16. Saves da v3.6.0, versão 15, recebem o novo estado de memória vazio e inicializam as quatro atribuições ao carregar. A escrita agora usa arquivo temporário verificado e backup do save anterior.

## Correções incorporadas da Etapa 7

- A escolha de espécie do recrutamento aciona autosave imediatamente.
- Uma oferta antiga em andamento reconstrói os pontos e o nível do vínculo ao carregar.
- A janela de recrutamento usa área rolável, uma ou duas colunas conforme a largura e ciclo de foco contido.
- A validação cruza avaliações aprovadas, vagas pendentes/concluídas, oferta ativa e sequência de IDs de recrutas.

## Limites da evidência

Os verificadores incluídos inspecionam código, referências e contratos estruturais. Eles não executam GDScript nem comprovam renderização, navegação real, áudio ou comportamento dentro do motor. A promoção para estável depende do roteiro manual em Godot.
