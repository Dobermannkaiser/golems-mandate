# Como cadastrar um personagem

A ferramenta simples de cadastro usa recursos do Godot em `res://characters/`.

## Passos

1. Duplique `characters/character_template.tres.example`.
2. Renomeie a cópia para um nome terminado em `.tres`.
3. Preencha um `character_id` único, usando letras minúsculas e sublinhado.
4. Informe nome, espécie, pronomes, papel, personalidade e biografia.
5. Coloque o busto PNG transparente em `res://assets/dialogue/portraits/`.
6. Ajuste `portrait_path` para esse arquivo.
7. Marque as flags necessárias:
   - `is_founder_appearance`: aparência sorteável de fundador;
   - `is_special_npc`: personagem nomeado especial;
   - `romance_available`: preparação para a Etapa 8;
   - `hidden_until_story`: mantém o personagem fora da campanha atual.
8. Inicie o jogo e execute **TESTE INTERNO**.

## Retrato único

A Etapa 6 usa apenas um busto por personagem. O método aceita um nome de expressão para manter compatibilidade futura, mas sempre retorna o mesmo retrato por enquanto.

## Regras de segurança

- Não reutilize `character_id`.
- Não apague o cadastro `mimo`.
- Mantenha pelo menos quatro aparências com `is_founder_appearance = true`.
- Prefira PNG com fundo transparente.
- Não renomeie um `character_id` que já esteja sendo usado por saves sem preparar migração.
