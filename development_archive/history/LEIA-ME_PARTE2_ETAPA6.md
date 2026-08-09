# Square Village — Parte 2, Etapa 6

## Retratos e sistema de diálogo — v2.6.1

Esta versão promove o layout aprovado da v2.5.4.d e adiciona uma base reutilizável para conversas, retratos, escolhas e futuros acontecimentos narrativos.

## Conteúdo implementado

- Caixa de diálogo integrada ao layout da vila.
- Retrato único por personagem, com fundo transparente.
- Fallback por iniciais e cor quando uma imagem estiver ausente.
- Efeito de digitação, clique para completar e novo clique para avançar.
- Respostas do jogador identificadas como **Prefeito**.
- Histórico pequeno da conversa atual.
- Conversas de demonstração para Mimo e para os quatro fundadores.
- Personalidade de Mimo: boba, engraçada, fofa, confiante e leal.
- Cinco aparências genéricas de Passos-Leves para quatro fundadores.
- Sorteio sem repetição e persistência da aparência no save.
- Cadastro de Mimo e quatro NPCs futuros em recursos `.tres`.
- Fonte Alagard aplicada às conversas, eventos e ferramenta de teste.
- Ferramenta interna de diagnóstico na barra lateral.

## Expansão de aleatoriedade

- Lista de nomes procedurais ampliada de 20 para 40 nomes.
- Catálogo de acontecimentos ampliado de 20 para 40 eventos.
- Os 20 acontecimentos novos usam magia, criaturas, relíquias, portais, fadas, dragões, espíritos e fenômenos arcanos.
- A chance de acontecimento aleatório ao encerrar o dia caiu de 70% para 52,5%, uma redução relativa de 25%.
- Eventos obrigatórios de capítulo e avaliação não foram removidos por essa alteração.

## Retratos dos fundadores

Em uma campanha nova, os quatro fundadores recebem quatro aparências diferentes entre cinco opções. O identificador do retrato é salvo junto ao personagem e não deve mudar ao carregar a campanha.

Saves antigos recebem aparências ausentes de forma automática. Caso haja repetição herdada de uma versão anterior, a rotina tenta redistribuir os retratos sem alterar nomes, atributos ou profissões.

## Como conversar

1. Selecione um representante no cartão ou na Área da Vila.
2. Clique novamente no mesmo representante.
3. Durante a fala:
   - clique, Enter ou Espaço completa o texto;
   - use **Continuar** para avançar;
   - escolha uma resposta quando as opções aparecerem;
   - use **Histórico** para rever a conversa atual.

## Teste interno

O botão **TESTE INTERNO** fica na barra lateral. Ele verifica:

- cadastros e retratos;
- IDs duplicados;
- aparências exclusivas dos fundadores;
- grafos e destinos de diálogo;
- estrutura dos 40 acontecimentos;
- custos, efeitos, testes e estações dos eventos;
- Conselho, população, campanha, construções e previsão;
- fonte e scripts principais da Etapa 6.

O diagnóstico também oferece um diálogo de teste separado.

## Compatibilidade

O formato de save existente foi preservado e apenas recebeu o campo persistente `portrait_id` para os personagens. Recomenda-se fazer uma cópia do save antes de testar qualquer versão de desenvolvimento.

## NPCs preparados para etapas futuras

Os seguintes personagens estão cadastrados, com retratos e descrições, mas permanecem ocultos até suas entradas narrativas:

- Brunna Ana — anã bárbara e ferreira ritualista;
- Orion Escamagelo — draconato pesquisador arcano;
- Rubra Verbum — meio-demônia estudiosa;
- Kobi Cobre-Fino — kobold mercante.
