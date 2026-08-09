# Golem's Mandate — Parte 3, Etapa 6 — v3.5.1

## Objetivo

Esta revisão foi criada sobre a v3.5.0 testada pelo usuário. Ela não altera balanceamento, regras das builds, acontecimentos, diálogos, progressão ou formato do save. O objetivo é reduzir trabalho desnecessário no carregamento, limpar recursos sem uso e organizar o projeto para o Godot importar apenas o que pertence ao jogo ativo.

## Alterações principais

### Interface criada sob demanda

Na v3.5.0, quinze janelas completas eram construídas durante a abertura do jogo, embora permanecessem ocultas até serem usadas. Na v3.5.1, somente a interface principal e o menu inicial são criados no primeiro quadro. As demais janelas são criadas ao primeiro uso:

- acontecimentos;
- campanha;
- recrutamento;
- aviso de estação;
- construções;
- salvar/carregar;
- tutorial;
- Conselho;
- histórico da carta;
- detalhes da previsão;
- vila ampliada;
- diálogos;
- diagnóstico;
- relacionamentos;
- configuração do Prefeito.

Isso reduz nós, controles e conexões ocultos mantidos desde o início da partida.

### Cache do catálogo de personagens

O catálogo de personagens não abre mais a pasta `characters` e recarrega todos os arquivos `.tres` a cada solicitação de retrato ou personagem. Agora existem caches para:

- lista de definições;
- busca por ID;
- fundadores disponíveis;
- texturas de retrato já solicitadas.

### Limpeza da cena principal

A cena `main.tscn` passou de 27 para 10 nós. Foram removidos o painel antigo, o fundo antigo e o chão antigo, que já eram escondidos pela interface atual. O contêiner `World/Villagers` e os cinco modelos necessários ao estado do jogo foram preservados e começam ocultos.

### Limpeza de recursos

Foram removidos 29 arquivos ativos sem referência, incluindo:

- cópias antigas de retratos de relacionamentos;
- sprites antigos substituídos pelos sprites por nível;
- folha antiga dos moradores;
- terrenos e caminhos antigos;
- uma segunda cópia da fonte;
- retrato provisório já substituído.

Os arquivos de licença e de origem dos áudios foram preservados.

### Organização do projeto

- 172 relatórios históricos foram preservados em `development_archive/history`;
- `development_archive` possui `.gdignore`;
- `tools` também possui `.gdignore`;
- caches Python passaram a ser ignorados no Git.

Essas mudanças limpam a árvore do editor, mas não são apresentadas como aumento direto de FPS.

## Compatibilidade

- versão pública: `3.5.1`;
- versão do save: `15`;
- saves válidos da v3.5.0 devem continuar compatíveis;
- não é necessário iniciar campanha nova em relação à v3.5.0.

## Limite da validação

O Godot não foi baixado, instalado ou executado. Foram realizados análise estática, verificações de referências, auditoria de recursos, verificadores estruturais e simulações de regras. O teste de runtime continua pertencendo ao usuário.
