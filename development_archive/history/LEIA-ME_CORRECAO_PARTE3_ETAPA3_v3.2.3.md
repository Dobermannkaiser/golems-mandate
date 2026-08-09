# Golem’s Mandate — Parte 3 / Etapa 3 — correção v3.2.3

Esta versão parte da v3.2.2 e corrige os cinco problemas relatados durante o teste real.

## Correções

### XP das cartas

- cada carta ativa recebe **+2 XP** ao concluir um dia no Conselho;
- a carta responsável por resolver um acontecimento recebe **+20 XP**;
- o XP aparece imediatamente na carta;
- ao alcançar a exigência, a carta sobe de nível, preserva o excedente de XP e recebe um ponto de atributo não gasto para a etapa de evolução;
- nível, XP e pontos não gastos são persistidos no save.

### Transparência das artes

As imagens recebidas originalmente eram JPGs com fundo preto. Os 30 retratos novos usados nas cartas, diálogos e relações foram recortados, convertidos para PNG RGBA e validados com transparência real.

### Mimo

Mimo passa de **6/6/6/6** para **3/3/3/3**. Sua passiva Faz-tudo e sua presença fixa na reserva permanecem.

### Recrutamento após avaliações

Após cada avaliação aprovada nos dias **20, 40, 60, 80, 100 e 120**, o jogo apresenta duas cartas:

- ambas são da espécie do NPC de relacionamento elegível com maior amizade;
- o mesmo NPC não pode originar outra oferta;
- quando o vínculo mais alto já foi usado, o sistema escolhe o próximo vínculo elegível;
- a carta escolhida entra na reserva do Conselho;
- nomes, retratos, atributos, passiva e personalidade são gerados para as duas candidatas;
- ofertas pendentes e cartas recrutadas são salvas e carregadas.

### Legibilidade das cartas

- sombra e contorno de fonte foram removidos dos textos das cartas;
- a remoção também alcança o texto da seção expandida;
- as cartas não usam escala fracionária durante seleção ou entrada.

## Save

O save passa para a versão **11**. É necessária uma **nova campanha** para testar esta versão.

## Validação realizada

- 571 verificações estruturais, sem falhas;
- 10.000 campanhas simuladas para as cartas iniciais;
- simulação específica de XP, sem falhas;
- 10.000 campanhas e 60.000 ofertas simuladas para recrutamento, sem repetição de NPC fonte;
- 30 retratos verificados quanto a resolução, canal alfa e transparência.

## Limite honesto

O Godot não foi executado neste ambiente. O projeto ainda precisa ser validado em runtime no Godot 4.7.1 pelo usuário.
