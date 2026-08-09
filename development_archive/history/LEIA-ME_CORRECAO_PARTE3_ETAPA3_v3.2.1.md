# Golem’s Mandate — Parte 3 / Etapa 3 — v3.2.1

Correção da versão v3.2.0 após teste real no Godot.

## Corrigido

- legibilidade das cartas:
  - remoção de escalas fracionárias que borravam o texto;
  - tamanhos de fonte aumentados;
  - cartas ampliadas para comportar as informações sem sobreposição;
  - snap de controles para pixels habilitado;
- profissão restaurada como mecânica central:
  - cada carta ativa possui um seletor explícito de profissão;
  - a alteração atualiza a profissão do habitante, a previsão e a produção;
  - cartas na reserva não podem exercer profissão;
- preparação dos NPCs:
  - dias narrativos 15, 30, 45, 60 e 75 agora são aceitos;
  - Orion e os demais NPCs deixam de falhar por não chegarem em dia de auditoria;
- modo de teste de relações:
  - Mimo, Aelric, Kobi, Orion, Rubra e Brunna ficam disponíveis para inspeção.

## Mantido

- avaliações nos dias 20, 40, 60, 80, 100 e 120;
- chegada narrativa dos NPCs nos dias 15, 30, 45, 60 e 75;
- geração procedural das quatro cartas iniciais;
- Mimo como carta de reserva;
- save exclusivo da Etapa 3.

## Limitação honesta

O projeto não foi executado no Godot neste ambiente. A validação estrutural passou,
mas o teste visual e de runtime continua dependendo do usuário.
