# Golem’s Mandate — Parte 3 / Etapa 5 — v3.4.0

## Base utilizada

Esta versão foi construída sobre uma extração limpa da **v3.3.2**, validada pelo usuário como base estável oficial.

A v3.4.0 é uma **versão candidata** até ser aberta e testada pelo usuário no Godot.

## Passivas

O catálogo provisório foi substituído por quinze passivas permanentes:

- Adaptável;
- Dedicado;
- Inquieto;
- Versátil;
- Rival Produtivo;
- Organizador;
- Veterano;
- Incansável;
- Autossuficiente;
- Econômico;
- Motivador;
- Otimista;
- Improvisador;
- Protetor;
- Mediador.

Mimo mantém **Faz-Tudo** como passiva exclusiva.

Cada passiva possui nome, efeito, condição e estado atual. Na carta:

- **ATIVA / verde:** efeito aplicado na situação atual;
- **CONDICIONAL / amarelo:** a condição ainda não foi cumprida ou aguarda um acontecimento adequado;
- **INATIVA / cinza:** não produz efeito na situação atual.

Os fundadores recebem passivas diferentes. Recrutamentos priorizam passivas ainda ausentes do elenco, e as duas candidatas de uma mesma oferta nunca compartilham passiva.

## Retorno por concentração profissional

A penalidade não altera a produção histórica individual das cartas. Ela é aplicada igualmente ao **total final que entra no estoque**:

- uma carta na profissão: 100%;
- duas cartas na mesma profissão: 97%;
- três cartas: 93%;
- quatro cartas: 88%.

Assim, concentrar o Conselho continua possível em emergências, mas possui um custo econômico claro.

## Sinergias automáticas

O sistema reconhece cinco composições:

- **Ciclo de Sustento:** Agricultor + Coletor — +3% alimentação;
- **Forja Abastecida:** Ferreiro + Coletor — +3% material;
- **Obras Protegidas:** Ferreiro + Guarda — -0,25 manutenção diária;
- **Ordem Comunitária:** Servidor Público + Guarda — +0,25 felicidade diária;
- **Conselho Diverso:** quatro profissões diferentes — +2% em toda produção do Conselho.

Não existe ativação manual. O sistema escolhe automaticamente a melhor combinação estimada para o próximo dia, obedecendo:

- máximo de duas sinergias simultâneas;
- cada carta participa de no máximo uma sinergia;
- composições qualificadas, mas excluídas pelo limite, continuam visíveis no detalhamento.

## Previsão detalhada

O botão **DETALHAR MODIFICADORES** abre um painel recolhido por padrão com:

- produção antes da composição;
- entrada final prevista;
- passivas e estados das quatro cartas;
- sinergias escolhidas automaticamente;
- sinergias qualificadas que ficaram fora do limite;
- penalidade por concentração;
- consumo de alimentação antes e depois das reduções;
- manutenção antes e depois das reduções;
- ordem de aplicação dos modificadores.

## Integrações

- Dedicado usa dias consecutivos na mesma profissão;
- Inquieto usa os três primeiros dias após uma troca real;
- Versátil consulta o histórico de dias por profissão;
- Veterano acompanha o nível;
- Incansável adiciona 1 XP ao ganho diário;
- Autossuficiente reduz consumo pelo equivalente a um habitante;
- Econômico reduz manutenção total em 0,30;
- Motivador e Otimista alteram felicidade;
- Improvisador melhora testes arriscados em 5 pontos percentuais;
- Protetor reduz em 15% apenas efeitos negativos de falhas, sem reduzir custos prévios;
- Mediador melhora uma alteração de relação por dia quando a carta é responsável.

## Tutoriais e guia

O tutorial foi elevado para a versão 5. Foram revisados:

- tutorial básico de recursos e previsão;
- tutorial básico dos representantes;
- explicação dos acontecimentos e passivas de responsabilidade;
- Guia do Jogo;
- ajuda contextual do Conselho;
- instruções de salvamento e campanha nova.

Foram removidas referências às passivas provisórias e a promessas de migração incompatíveis com esta etapa.

## Save

- schema: `golems_mandate_part3`;
- versão do save: 14;
- esta etapa exige uma campanha nova.

## Validação realizada

- verificação estrutural da Etapa 5;
- regressões das Etapas 3 e 4;
- verificação heurística de escopo local GDScript;
- simulação econômica de 120 dias nas três dificuldades;
- 120.000 Conselhos aleatórios na simulação de estresse;
- regressões de cartas, progressão, recrutamento e transparência.

O maior aumento acumulado no modelo econômico foi **+4,17%**. Na simulação de estresse, o maior aumento produtivo observado foi **+5,27%**, abaixo do limite aprovado de 12%.

O Godot não foi utilizado nesta validação.
