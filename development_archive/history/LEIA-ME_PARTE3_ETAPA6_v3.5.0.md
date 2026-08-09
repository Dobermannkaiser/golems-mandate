# Golem’s Mandate — Parte 3, Etapa 6 — v3.5.0

## Status
Versão candidata construída sobre a base estável v3.4.1. A v3.4.1 continua sendo a base oficial até validação no Godot pelo usuário.

## Conteúdo da Etapa 6

### Builds finais das construções
As cinco construções únicas passam a escolher uma especialização irreversível ao planejar o nível 3:

- Celeiro: Silo de Reserva ou Cozinha Comunitária;
- Serraria: Serraria Intensiva ou Oficina de Carpintaria;
- Poço: Reservatório Profundo ou Fonte Comunitária;
- Praça: Mercado Comunitário ou Jardim Público;
- Muralha: Bastião de Pedra ou Portões Vigilantes.

A escolha só se torna permanente quando a obra é concluída. Cancelar a obra antes da conclusão libera uma nova escolha.

### Efeitos econômicos
Cada build possui efeitos próprios de produção, consumo, felicidade, manutenção ou custo de obras futuras. Os efeitos são derivados do catálogo `BuildingVariantCatalog.gd` e integrados à previsão e ao fechamento diário.

### Acontecimentos
Foram adicionadas vinte interações especiais, duas por build. Elas aparecem apenas quando a build correspondente está concluída. O uso é registrado no histórico da construção.

### Reações dos NPCs
Foram adicionadas vinte reações narrativas: uma reação preferencial ligada a um NPC coerente e uma alternativa da Mimo. O Mercado Comunitário, por exemplo, recebe uma reação específica de Kobi Cobre-Fino.

### Aparências
Cada build possui uma aparência distinta. O nível 3 usa a textura da variante selecionada, e as duas builds da muralha também recebem detalhes procedurais próprios.

### Interface
A janela de construção compara as duas builds lado a lado, mostrando aparência, identidade, efeitos, custo, duração, interações conhecidas e aviso de irreversibilidade. Após a conclusão, mostra o nome da build, o dia de conclusão e quantas vezes ela foi utilizada em acontecimentos.

### Salvamento
- versão pública: 3.5.0;
- versão do save: 15;
- versão do tutorial: 6;
- as builds escolhidas, dias de conclusão e usos em acontecimentos são persistidos.

## Compatibilidade
Campanhas da v3.4.1 não são compatíveis, pois o schema do save foi elevado para 15. É necessário iniciar uma campanha nova para testar a Etapa 6.

## Limitação da validação
O Godot não foi baixado, instalado ou executado neste ambiente. A validação realizada foi estática: estrutura, referências, escopo local, integridade de PNGs, simulações econômicas, extração limpa do ZIP e checksum.
