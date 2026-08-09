# Square Village — Correção v2.6.1

Esta versão corrige quatro falsos positivos do **Oráculo de Diagnóstico**.

As escolhas `taste_berries`, `well_ask_treasure`, `broom_open` e `mimic_feed` usam uma chance fixa (`base_chance`) e, corretamente, não exigem um representante nem um atributo. O diagnóstico da v2.6.0 validava qualquer escolha com `base_chance` como se obrigatoriamente possuísse `test_attribute`, produzindo quatro erros incorretos.

Na v2.6.1, o atributo só é obrigatório quando `requires_villager` é verdadeiro. Eventos, probabilidades, efeitos, saves e diálogos permanecem inalterados.
