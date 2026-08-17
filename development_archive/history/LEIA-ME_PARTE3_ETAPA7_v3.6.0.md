# Golem's Mandate — Parte 3, Etapa 7 — v3.6.0

Versão candidata construída sobre a **v3.5.3 estável**.

## Objetivo

Consolidar o sistema de recrutamento já existente, corrigindo oportunidades perdidas, requisitos ausentes, desempates automáticos e informações incompletas de interface e save.

## Regras finais

| Avaliação aprovada | Relação exigida | Nível da carta |
|---:|---:|---:|
| Dia 20 | 50 | 2 |
| Dia 40 | 120 | 3 |
| Dia 60 | 220 | 4 |
| Dia 80 | 340 | 5 |
| Dia 100 | 480 | 6 |
| Dia 120 | 620 | 6 |

- A avaliação precisa ser aprovada.
- O NPC fonte não pode originar duas ofertas.
- A vaga mais antiga tem prioridade.
- Requisito não cumprido deixa a vaga pendente.
- A vaga volta a ser verificada na próxima avaliação aprovada.
- Depois do Dia 120, nenhuma vaga nova é criada; vagas antigas ainda pendentes são rechecadas quando um vínculo muda.
- O vínculo elegível com mais pontos define a espécie.
- Empate exato entre espécies diferentes permite escolher a espécie.
- Depois aparecem duas candidatas da mesma espécie.
- A candidata escolhida entra na reserva.
- O nível depende da vaga original, não do dia em que ela finalmente foi resolvida nem da média do Conselho.

## Interface

A janela do Conselho agora informa:

- quantos recrutamentos foram concluídos;
- qual vaga está aguardando;
- requisito e pontuação atual;
- pontos que ainda faltam;
- oferta pronta;
- estado final dos seis recrutamentos.

A janela de oferta possui duas fases quando há empate:

1. escolha da espécie;
2. comparação das duas candidatas.

## Save e migração

O save global continua na **versão 15**. O estado interno do recrutamento passou para a versão 2 e migra automaticamente o formato anterior.

Portanto, **não é necessário iniciar campanha nova** em relação à v3.5.3.

## Verificação

A versão passou por verificadores estáticos, simulações de campanha, validação de recursos e regressões das Etapas 3 a 6. O Godot não foi executado.
