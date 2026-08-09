# Square Village — Revisão com as skills Godot — v2.10.1

Esta manutenção revisa a versão estável v2.10.0 usando dois referenciais internos:

- **Godot — Programação para Jogos**;
- **Godot — UX e UI para Jogos**.

A revisão foi deliberadamente conservadora. Economia, campanha, dificuldades, metas, história, relacionamentos, áudio, construções e balanceamento permanecem iguais à v2.10.0.

## Melhorias de arquitetura

- criado `VillageUIAccessibility`, um helper único para foco, restauração de foco, configuração de controles e mensagens semânticas;
- padronizado o contrato `hide_window()` da janela do Conselho;
- preservado o save v7 e o arquivo de campanha da v2.10.0;
- configurações globais receberam schema próprio, separado do save da campanha;
- Oráculo de Diagnóstico passou a verificar recursos e preferências de UX/UI;
- criado um verificador específico para a revisão baseada nas duas skills.

## Melhorias de UX e UI

- foco inicial seguro ao abrir páginas e modais;
- retorno do foco ao controle anterior ao fechar uma janela;
- `ui_cancel`/Esc padronizado nas janelas que permitem retorno;
- confirmação destrutiva inicia no botão **Cancelar**;
- botões e ações principais receberam áreas mínimas mais confortáveis;
- tooltips adicionados às ações mais ambíguas;
- respostas visuais usam `[OK]` e `[ATENÇÃO]`, não apenas cor;
- escolhas de diálogo recebem foco automaticamente;
- histórico de diálogo pode ser fechado com a ação de voltar;
- Guia do Jogo ganhou uma página de acessibilidade e navegação.

## Novas preferências globais

Em **Configurações**:

- **Texto instantâneo:** mostra diálogos completos sem escrita gradual;
- **Contraste reforçado:** intensifica fundos, bordas, realces e foco;
- **Restaurar acessibilidade:** restaura movimento, texto e contraste sem alterar volumes.

As preferências são aplicadas imediatamente e persistem globalmente.

## Compatibilidade

- saves válidos da v2.10.0 continuam compatíveis;
- o schema de campanha permanece v7;
- configurações antigas são carregadas com valores seguros para as novas opções;
- nenhuma nova campanha é exigida.

## Validação

- verificador estrutural da Etapa 10;
- verificador específico das duas skills;
- simulação econômica de 1.800 campanhas repetida em `SIMULACAO_ECONOMICA_120_DIAS_v2.10.1.txt`, sem alteração de resultados;
- compilação dos scripts Python;
- teste de integridade do ZIP.

O Godot não estava instalado no ambiente de geração. A execução visual e funcional final deve ser realizada no motor seguindo o roteiro incluído.
