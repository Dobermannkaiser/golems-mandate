# Golem's Mandate — Parte 3, Etapa 12 — v3.11.0

Esta versão implementa o sistema de preparação, memória de avaliação e encerramento descritivo da campanha sobre uma cópia exata da base estável `v3.10.1`.

## O que mudou

- Cada campanha agora possui nome de vila, semente numérica reproduzível, versão do gerador, data de criação e versão do projeto em que foi criada.
- A tela de criação aceita uma semente numérica ou uma palavra, sugere um nome de vila, gera outra semente e permite copiá-la.
- Gerações com efeito de jogabilidade usam a semente da campanha. Variações exclusivamente visuais e sonoras continuam independentes.
- As três dificuldades foram preservadas, mas agora se explicam por condições concretas: reservas e metas, atração/abandono, tolerância e recuperação de crise e janela das memórias dos fundadores. Os multiplicadores diretos de produção, consumo, manutenção, desgaste e custo permanecem neutros.
- A preparação para a próxima avaliação mostra valor atual, projeção e meta por recurso.
- A projeção inclui somente obras já contratadas que ficarão disponíveis antes da avaliação. Escolhas futuras, eventos, novas obras e trocas de Conselho não são antecipados.
- Cada avaliação preserva as metas realmente julgadas, o movimento dos recursos no período, as contribuições individuais, profissões, passivas, especializações, decisões, fatores, consequências e comparação com a avaliação anterior.
- Medalhas comportamentais reconhecem ações observadas e não concedem bônus.
- O encerramento apresenta estatísticas separadas e um perfil descritivo. Não existe pontuação geral nem classificação entre campanhas.
- O histórico global mostra a campanha mais recente e os perfis anteriores, sem selecionar uma campanha “melhor”.

## Medalhas comportamentais

- Sustento da Vila
- Mãos à Obra
- Coração da Comunidade
- Espírito Versátil
- Guarda nas Horas Difíceis
- Voz da Conciliação
- Companheiro Leal
- Virada Decisiva

O algoritmo é determinístico, atribui no máximo uma medalha de cada categoria e no máximo uma medalha a cada conselheiro por avaliação.

## Perfis finais

Os perfis possíveis incluem Administração Comunitária, Vila Próspera, Conselho Resiliente, Crescimento Arriscado, Diplomacia Exemplar e Administração Equilibrada. O perfil é uma síntese textual; as estatísticas que o sustentam continuam visíveis separadamente.

## Persistência

O envelope global continua na versão `18` e no mesmo caminho da Parte 3. Os subsistemas evoluíram de forma localizada:

- campanha: schema `5`;
- fundação telemétrica: schema `4`;
- acontecimentos: semente e estado do RNG opcionais no mesmo bloco;
- perfil: identidade e dados de criação opcionais no mesmo bloco.

A validação da fila de obras agora aceita o schema `2`, que já era o schema efetivamente exportado pelo gerenciador desde a base `v3.10.1`.

## Verificação realizada sem Godot

- integridade e SHA-256 do ZIP-base conferidos;
- base extraída para uma cópia de trabalho separada;
- `222/222` contratos no verificador estático da Etapa 12;
- `75/75` scripts analisados por uma gramática independente de GDScript, sem erro sintático;
- todas as referências literais `res://` verificadas;
- ZIP-base `v3.10.1` mantido intacto.

O Godot não foi inicializado. A validação de runtime, visual, foco, áudio e jogabilidade continua sendo responsabilidade do teste manual do usuário. A simulação extensa de balanceamento também não foi executada sem autorização específica.

