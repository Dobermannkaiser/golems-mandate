# Golem’s Mandate — Parte 3, Etapa 2 — v3.1.2

Correção refeita sobre uma extração limpa da v3.1.0, que foi a versão testada e funcional no Godot.

## Motivo da nova correção

A v3.1.1 foi empacotada sem uma revisão adequada de importação limpa. Embora os arquivos essenciais estivessem presentes no ZIP, `project.godot` ainda dependia de UIDs para localizar a cena principal e o autoload `GameManager`. Em uma importação nova, esses UIDs não foram reconhecidos e o carregamento do projeto falhou em cascata.

A v3.1.1 deve ser descartada.

## Corrigido na v3.1.2

- `run/main_scene` agora usa `res://scenes/main.tscn`;
- autoload `GameManager` agora usa `res://scripts/GameManager.gd`;
- `GameSettings` e `AudioManager` permanecem com caminhos `res://` explícitos;
- erro de formatação em `RelationshipCatalog.gd` removido sem usar o operador `%` nas descrições problemáticas;
- muralha normal e ampliada reposicionada um pouco mais para baixo;
- indicador de casas extras movido para o canto inferior direito da área da vila;
- indicador alterado para `MORADIAS: +N casas`, com fonte maior e contorno forte;
- versão visual e diagnóstica atualizada para v3.1.2.

## Não alterado

- fila de obras;
- tempos de construção;
- cancelamento e reembolso;
- economia;
- saves e schema v9;
- tutorial e Guia do Jogo;
- conteúdo narrativo e relações, além da correção de formatação.

## Empacotamento

O ZIP da v3.1.2 possui `project.godot` diretamente na raiz para permitir importação mais segura pelo Gerenciador de Projetos do Godot.

## Validação realizada

- 899 verificações principais, 0 falhas;
- 72 verificações específicas de UX/UI, 0 falhas;
- 65 verificações gerais de UX/UI, 0 falhas;
- nenhuma ausência em comparação com os 293 arquivos da v3.1.0;
- arquivos críticos e autoloads confirmados;
- ZIP extraído em pasta vazia e validado novamente.

O Godot não está disponível neste ambiente, então a execução real continua dependendo do teste do usuário.
