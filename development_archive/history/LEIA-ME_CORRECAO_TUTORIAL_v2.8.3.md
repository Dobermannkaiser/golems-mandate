# Square Village — Correção dos tutoriais contextuais v2.8.3

## Problema corrigido

Os tutoriais contextuais de Conselho e Relações eram desenhados acima das janelas abertas, mas a janela modal inferior ainda podia receber os cliques primeiro. Isso fazia os botões **Próximo**, **Voltar** e **Fechar dica** parecerem travados.

## Solução

- a janela inteira do tutorial agora usa prioridade absoluta acima dos demais modais;
- o tutorial é movido para a frente ao ser aberto;
- a camada do tutorial assume a entrada do mouse somente enquanto está visível;
- ao fechar, a camada volta a ignorar entrada e não bloqueia o jogo;
- os três botões possuem foco explícito;
- **Esc**, **seta esquerda** e **seta direita** funcionam como navegação de segurança.

Nenhuma mecânica, relacionamento, evento ou regra de campanha foi alterada.
