# Golem's Mandate — Parte 3, Etapa 9 — v3.8.0

## Status

Esta entrega é uma **candidata para teste no Godot**. Ela foi construída sobre a v3.7.0 estável e não a substitui até que o roteiro manual seja concluído e aprovado.

## Silas e Dália

Silas Nocturno e Dália Folhaverde foram incorporados ao mesmo sistema dos demais personagens com roda de relacionamento. Não existe categoria especial nem fluxo paralelo.

- Silas chega no capítulo do Dia 90.
- Dália chega no capítulo do Dia 105.
- A cadência narrativa continua sendo de quinze dias.
- Depois da apresentação, ambos usam a mesma roda, conversas, pontos, eventos pessoais e regras de romance dos demais.

Silas é um meio-vampiro de 21 anos, músico e vigia, com humor seco e sensibilidade escondida sob uma aparência gótica. Dália é uma bruxa de 21 anos, herborista confiante e sociável, cuja história trata cultivo e cuidado como trabalho comunitário.

## Rotas e romance

Todos os sete candidatos românticos agora seguem a mesma regra de intenção. Os eventos pessoais permanecem nos níveis 2, 4, 6 e 8. Nos eventos dos níveis 4 e 6 surge uma escolha adicional, escrita como demonstração clara de interesse.

O romance no nível 8 só aparece quando as duas escolhas foram registradas. Sem elas, o vínculo conclui em amizade profunda. Se o romance for oferecido e rejeitado, a rota íntima daquele personagem é encerrada definitivamente, mas os pontos, conversas e amizade continuam. Um compromisso assumido bloqueia novos romances e mantém as outras rotas em amizade.

A roda informa quantas demonstrações foram registradas e quando a rota íntima foi encerrada. As escolhas e seus IDs são salvos, impedindo repetição ou romance acidental depois de carregar.

## Passivas

O desbloqueio existente foi preservado: o benefício de gestão é liberado no nível 4 da roda, correspondente a 340 pontos na tabela atual.

- **Silas — Canção de Vigília:** quando o dia termina com perda líquida de felicidade, recupera 1 ponto na manhã seguinte. Possui intervalo de cinco dias.
- **Dália — Horta Partilhada:** concede +4% de produção de alimentação quando a produção diária prevista é menor que o consumo.

As duas funcionam pela amizade e não exigem romance. A condição e o efeito aparecem na roda e no resumo do dia. Os modificadores de compromisso dos personagens antigos foram preservados como comportamento da versão estável.

## Diálogos, vila e acontecimentos

Silas e Dália possuem quatro falas sazonais, quatro assuntos regulares, quatro eventos pessoais, respostas próprias e falas de encontro. O sistema também aceita comentários sobre o estado real da vila: Dália reage ao saldo diário de alimentação negativo e Silas à felicidade muito baixa.

Os capítulos novos demonstram a integração mecânica:

- amizade com Rubra pode revelar contexto adicional no acontecimento de Silas;
- amizade com Aelric pode liberar uma solução de irrigação no acontecimento de Dália;
- possuir parceiro oficial libera uma variante comunitária no capítulo de Dália;
- opções de relacionamento não são automaticamente superiores às soluções comuns.

## Retratos e expressões

Os retratos já existentes de Bruxinha e Meio-vampiro foram reutilizados como arte temporária, sem geração de imagens. A infraestrutura agora aceita arquivos separados por expressão. Enquanto esses arquivos definitivos não forem fornecidos, a janela comunica seis estados por variação visual do retrato: neutro, feliz, triste, irritado, surpreso e afetivo/envergonhado.

## Persistência

O save passou para a versão 17. Saves válidos da v3.7.0, formato 16, recebem:

- marcadores persistentes de interesse romântico;
- último dia de ativação da passiva de Silas;
- versão 3 do estado de relacionamentos;
- Silas e Dália preparados como personagens ainda desconhecidos, preservando o progresso anterior.

Saves antigos que já mantinham interesse ou parceiro oficial recebem os dois marcadores legados para não perder uma rota previamente aberta.

## Limites da evidência

Os verificadores incluídos inspecionam referências, conteúdo e contratos estruturais. Eles não executam o parser, o runtime, o renderizador ou a navegação real do Godot. Nenhuma imagem foi gerada e nenhuma simulação extensa foi executada. A promoção para estável depende do roteiro manual no motor.
