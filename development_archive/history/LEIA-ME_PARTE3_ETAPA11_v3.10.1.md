# Golem's Mandate — Parte 3, Etapa 11 — v3.10.1

Base estável de origem: `v3.9.0`, validada no Godot pelo usuário. Esta entrega é uma candidata e não substitui a base estável até novo teste no motor.

## Cenas de relacionamento

- Cada um dos oito vínculos possui quatro cenas importantes, liberadas exatamente em `200`, `400`, `600` e `800` pontos.
- Os marcos são apresentados como Amizade, Confiança, Intimidade e Decisão.
- As cenas de `400` e `600` permitem registrar as duas demonstrações de interesse dos sete candidatos românticos.
- A cena de `800` usa a ilustração correspondente fornecida pelo usuário antes da escolha final.
- Amizade profunda está sempre disponível na decisão final.
- Romance só aparece na cena de `800`, exige as duas demonstrações de interesse e respeita a exclusividade de um parceiro oficial.
- `Decidir depois` não conclui a cena, não rejeita romance e mantém a decisão disponível.
- Mimo permanece exclusivamente na rota de amizade.
- Se uma imagem não puder ser carregada, a conversa usa o retrato normal como fallback e continua funcional.

## Vila e representantes

- Aldeões e representantes do mapa agora são peças procedurais simplificadas de jogo de tabuleiro.
- Representantes possuem cores estáveis, padrões, inicial do nome e aro de seleção; a identificação não depende apenas da cor.
- A felicidade da vila possui quatro respostas visuais localizadas: convivência animada, rotina estável, preocupação e crise.
- As faixas alteram marcas das peças, ritmo de movimento e pequenos sinais no centro da vila, sem filtro de cor sobre a tela inteira.
- Construções, conclusões, acontecimentos, avaliações e encerramentos produzem feedback visual curto no mapa.
- A preferência `Reduzir Animações` também é respeitada pelos novos movimentos e feedbacks.

## Limites confirmados

- Não foram criadas variantes de canteiro: todas as obras continuam usando o mesmo desenho procedural genérico com progresso.
- Não foi criado nenhum pacote ou diretório novo de decoração.
- As dez variantes finais de edifícios da etapa anterior foram preservadas.
- As oito imagens recebidas foram incorporadas sem edição.

## Persistência

- Save global permanece na versão `18`.
- A Etapa 11 não adiciona campos persistentes: marcos, imagens e resposta visual são derivados do estado já salvo.
- Saves da base `v3.9.0` são compatíveis diretamente, sem migração adicional.
- A validação estrutural continua obrigatória e agora identifica a seção inválida; a auditoria cruzada redundante não bloqueia mais snapshots produzidos pelo próprio jogo.

## Correções da v3.10.1

- Corrigidas duas expressões compostas que aplicavam formatação numérica ao trecho errado e geravam erros repetidos.
- O Oráculo valida atributos atuais conforme nível e pontos gastos, sem confundir progressão com a ficha inicial.
- Mimo pode ser movida normalmente entre Conselho e reserva sem produzir falso erro no Oráculo.
- O botão `ENCERRAR O DIA` informa a pendência e restaura acontecimentos ou conversas obrigatórias ocultos pelo Guia.

## Limite da validação

O Godot não foi executado, conforme a regra do projeto. Foram realizadas verificações estáticas, de recursos e de integridade. A candidata depende do roteiro manual no motor antes de ser promovida a base estável.
