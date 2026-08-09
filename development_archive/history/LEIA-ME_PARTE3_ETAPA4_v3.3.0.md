# Golem’s Mandate — Parte 3, Etapa 4 — v3.3.0

Versão candidata construída sobre a base estável v3.2.3.

## Experiência

- +2 XP ao final do dia para cada carta que terminou o dia ativa no Conselho;
- cartas na reserva não recebem o XP diário;
- +20 XP para a carta responsável por um acontecimento;
- +10 XP para cada novo marco pessoal de 100 unidades de alimentação, material ou felicidade;
- produção pessoal considera atributos, profissão, passiva e estação;
- bônus globais, construções, relacionamentos e recursos recebidos por eventos não são atribuídos à produção pessoal.

## Níveis e atributos

- fórmula: `80 + 20 × (nível atual − 1)`;
- nível máximo 6;
- XP vitalício continua sendo registrado no nível máximo;
- cada nível concede 1 ponto de atributo pendente;
- distribuição manual na carta expandida;
- pontos podem ser guardados;
- cada atributo possui limite 8;
- sem redistribuição gratuita.

## Acontecimentos

A carta atualmente selecionada é pré-selecionada como responsável. O jogador pode trocar a carta antes de decidir, mas não precisa fazer uma seleção adicional em todos os eventos. A responsabilidade, o resultado e o XP entram no histórico pessoal.

## Diálogo de conquista

Cada subida de nível abre uma conversa obrigatória, com falas próprias para:

- Otimista;
- Cauteloso;
- Prático;
- Ambicioso;
- Gentil;
- Teimoso;
- Brincalhão;
- Pessimista.

As respostas são embaralhadas. A resposta coerente com a personalidade concede +1 do recurso pessoalmente mais produzido pela carta. Quando a carta ainda não possui produção dominante, a recompensa segue seu trabalho atual e o diálogo não afirma uma produção inexistente.

## Ficha histórica

A ficha permanece escondida até o jogador expandir a carta e selecionar **ABRIR FICHA HISTÓRICA**. Ela apresenta progressão, dias no Conselho e na reserva, produção pessoal, profissão mais exercida, marcos, responsabilidade em acontecimentos, resultados, avaliações e uma crônica resumida das conquistas.

## Novas cartas recrutadas

Entram no nível `floor(média do Conselho ativo) − 1`, com mínimo 1. Os pontos correspondentes ao nível inicial já vêm distribuídos proceduralmente, respeitando o limite 8.

## Save

- save versão 12;
- fundação histórica schema 2;
- campanha nova obrigatória;
- conversas de nível pendentes, XP, pontos, produção e ficha histórica são persistidos.

## Validação

- 588 verificações estruturais da Etapa 3: 0 falhas;
- 130 verificações específicas da Etapa 4: 0 falhas;
- 25.000 carreiras simuladas: 0 violações;
- regressões de cartas, fila de obras e transparência aprovadas.

O Godot não foi executado neste ambiente. A versão só pode ser promovida a base estável após teste real no motor.
