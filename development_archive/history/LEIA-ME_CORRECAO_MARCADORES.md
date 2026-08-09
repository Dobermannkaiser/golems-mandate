# Correção dos marcadores de construções

Esta versão preserva integralmente a Etapa 8 e corrige o erro:

`Node not found: "VBoxContainer/Name" em BuildingVisuals.gd`

## Causa

O `VBoxContainer` dos marcadores era criado por código sem receber um nome
estável. O Godot atribuía um nome interno como `@VBoxContainer@4`, enquanto o
script procurava pelo caminho literal `VBoxContainer/Name`.

## Correção

- o contêiner agora recebe o nome estável `Layout`;
- os rótulos são acessados por `Layout/Name` e `Layout/Level`;
- a busca usa `get_node_or_null`, evitando erros caso um marcador incompleto
  seja encontrado.

Nenhuma regra de campanha, construção, acontecimento ou salvamento foi
alterada.

## Teste

1. Importe o `project.godot` desta pasta.
2. Execute o projeto com `F5`.
3. Confirme que o depurador não registra o erro de `BuildingVisuals.gd`.
4. Abra `CONSTRUÇÕES`.
5. Melhore uma construção e confirme que o nome e o nível aparecem na vila.
6. Salve, pare o jogo, execute novamente e carregue a campanha.
