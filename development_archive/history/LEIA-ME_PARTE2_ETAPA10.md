# Square Village — Parte 2 — Etapa 10

> **Manutenção v2.10.1:** arquitetura, UX, UI e acessibilidade revisadas com as skills internas de Godot. Consulte `LEIA-ME_REVISAO_SKILLS_v2.10.1.md`. O balanceamento e o save v7 da v2.10.0 foram preservados.

## Balanceamento e acabamento — v2.10.0

A v2.10.0 conclui a Parte 2 com três dificuldades de campanha, 24 metas
obrigatórias, simulação econômica de 120 dias, medalhas de conclusão, revisão de
save/menu/tutorial e ferramentas de diagnóstico para o balanceamento.

## Dificuldades

A dificuldade é escolhida ao criar a vila e fica registrada no save:

- **Acolhedora:** indicada para história, relações e construção com menor pressão;
- **Moderada:** experiência principal, com margem para correção de alguns erros;
- **Difícil:** economia mais apertada e necessidade de planejamento antecipado.

A dificuldade altera metas, produção, consumo, manutenção, custos de obras,
felicidade, atração populacional e recursos iniciais. Os acontecimentos aleatórios
não receberam punições extras.

Saves válidos anteriores são convertidos para **Moderada**.

## As 24 metas

Existem quatro metas em cada uma das seis auditorias dos dias 20, 40, 60, 80,
100 e 120:

- população;
- alimentação;
- material;
- felicidade.

Falhar qualquer meta continua encerrando a campanha imediatamente. A tela de
Avaliação mostra os números completos da próxima auditoria e uma prévia das
seguintes, acompanhada pela leitura do Prefeito Perfeito.

## Outono e inverno

O outono continua sendo a melhor estação para formar reservas. O inverno mantém
produção menor, consumo maior e pressão sobre a felicidade. Personagens de
relacionamento, Sanctuary-Void e representantes receberam falas próprias sobre
preparação e estoque de alimentação.

## Medalhas e histórico

Ao vencer, a campanha recebe uma medalha de Bronze, Prata ou Ouro com base em:

- dificuldade;
- margem acima das metas;
- população e reservas finais;
- felicidade;
- crises e dias em situação crítica.

O menu principal mostra a melhor medalha já conquistada. O histórico global
registra até 30 vitórias, incluindo Prefeito, dificuldade, resultado econômico e
parceiro, quando houver.

## Simulação

O simulador executou 1.800 campanhas completas, totalizando 216.000 dias
simulados. Ele compara três políticas automatizadas em cada dificuldade. O
resultado serve para detectar extremos matemáticos e não substitui decisões reais,
acontecimentos completos ou o teste visual dentro do Godot.

Consulte `SIMULACAO_ECONOMICA_120_DIAS_v2.10.0.txt` para a matriz completa das
24 metas e as taxas observadas.

## Compatibilidade e testes

- esquema de save atualizado para v7;
- dificuldade persistida no perfil e na campanha;
- menu de carregamento exibe dificuldade, medalha e pontuação;
- tutorial inicial e Guia do Jogo atualizados;
- Teste Interno permite consultar metas por dificuldade e auditoria;
- muralhas procedurais e sistema de áudio da v2.9.2 foram preservados.

A validação estrutural está em `VERIFICACAO_ETAPA10_v2.10.0.txt`. O roteiro de
teste manual está em `ROTEIRO_DE_TESTE_ETAPA10_v2.10.0.txt`.
