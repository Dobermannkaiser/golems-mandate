# SquareVillage — Parte 2, Etapa 4 — Conselho e Especialistas (v2.4.2)


## Correção da v2.4.2

A v2.4.1 ainda continha uma referência obsoleta a
`VillagePopulationState.REPRESENTATIVE_COUNT` na previsão populacional. A
constante havia sido substituída durante a separação entre Conselho e moradores
nomeados, fazendo o Godot interromper a compilação do `GameManager.gd`.

Na v2.4.2:

- a previsão usa `protected_named_resident_count`, obtido do estado real da população;
- a regra prevista agora corresponde à regra aplicada ao fim do dia;
- cinco personagens nomeados permanecem protegidos contra abandono comum;
- o verificador passou a detectar referências inválidas a membros de classes do projeto;
- o save usa um arquivo próprio, separado das versões defeituosas.

## Correção da v2.4.1

A v2.4.0 tentava criar Mimo por código a partir do `GameManager`, que é um
*autoload*. Nesse momento, `get_tree().current_scene` ainda podia ser nulo e o
novo jogo falhava antes de a cena principal terminar de carregar.

Na v2.4.1:

- Mimo existe diretamente em `scenes/main.tscn`, inicialmente oculto e na reserva;
- o `GameManager` aguarda os cinco personagens reais da cena antes de concluir o elenco;
- não há acesso a `current_scene` durante a inicialização;
- o carregamento associa os personagens pelos seus IDs, e não pela ordem dos nós;
- o save corrigido usa um caminho próprio, separado da v2.4.0 defeituosa.

## Sistemas implementados

- População total e personagens nomeados são conceitos separados.
- O Conselho possui exatamente quatro representantes ativos.
- O elenco inicial contém quatro fundadores Passos-Leves e Mimo na reserva.
- Os fundadores continuam procedurais, com atributos limitados entre 3 e 9.
- Quatro especializações diferentes são sorteadas entre as cinco profissões.
- A janela **GERENCIAR CONSELHO** compara um membro ativo com a reserva.
- Trocas são gratuitas e ilimitadas antes de encerrar o dia.
- O personagem que entra herda a profissão da vaga substituída.
- Somente os quatro membros ativos produzem como especialistas e participam dos acontecimentos.
- A reserva continua pertencendo à população e participa da mão de obra comunitária.
- Especialização concede +5% à contribuição individual na profissão correspondente.
- Mimo possui **Polivalente**: +5% em qualquer profissão atribuída.
- A passiva **Faz-tudo** acrescenta +5% quando a profissão de Mimo é única no Conselho.
- Passivas iniciais: Adaptável, Econômico, Motivador, Cooperativo e Faz-tudo.
- Personagens nomeados são protegidos contra o abandono populacional comum.
- Estado do elenco, Conselho, reserva, profissão, especialização e passiva é salvo.
- A espécie foi padronizada como **Passos-Leves** em todo o projeto.

## Goblin ferreiro preparado

O catálogo contém o futuro goblin ferreiro com ID permanente, atributos,
especialização, passiva, dados de retrato e relacionamento. Ele permanece
invisível, desconhecido e não recrutável nesta etapa, aguardando o evento
narrativo futuro.

## Compatibilidade de save

- Formato interno: `save_version = 4`.
- Arquivo da v2.4.2: `square_village_part2_v2_4_2_save.json`.
- Saves da v2.3.0 e da v2.4.0 não são convertidos.
- Configurações gerais continuam separadas do save da campanha.

## Roteiro principal de teste

1. Abra `project.godot` no Godot 4.7 ou 4.7.1.
2. Inicie uma nova campanha e confirme que não há erro no depurador.
3. Confirme população `8/10` e exatamente quatro cartões ativos.
4. Abra **GERENCIAR CONSELHO** e confirme Mimo na reserva.
5. Escolha um fundador e realize a troca com Mimo.
6. Confirme que continuam existindo exatamente quatro cartões ativos.
7. Confirme que Mimo herdou a profissão da vaga substituída.
8. Altere a profissão de Mimo e observe a atualização imediata da previsão.
9. Troque Mimo novamente para a reserva e confirme que o antigo membro retorna.
10. Salve a campanha, volte ao menu e carregue o save.
11. Confirme nomes, profissões, Conselho e reserva após o carregamento.
12. Encerre um dia e confirme que a produção usa apenas os quatro ativos como especialistas.
13. Abra um acontecimento e confirme que apenas membros ativos aparecem como responsáveis.

## Verificação automatizada incluída

O arquivo `tools/verify_stage4.py` verifica a estrutura do projeto, caminhos de
recursos, delimitadores, funções duplicadas, configuração da cena, invariantes
do Conselho, integração do save, catálogo de especialistas e remoção do nome
antigo da espécie.

Execute a partir da pasta do projeto:

```bash
python tools/verify_stage4.py
```
