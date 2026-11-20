# Arquitetura do enois-cli

O `enois-cli` é o cliente de terminal do Énóis: mesmas telas e funcionalidades do
`enois-frontend`, renderizadas em TUI sobre a linguagem **Kof**.

## Por que Kof

- Compilador próprio (`kof` 0.8.0), alvo JVM com `kof.http`, `json` e `readLine()`
  nativos — o TUI precisa exatamente dessas três coisas.
- Empacota como fat jar (`kof build --fat`), sem runtime extra.
- Regras da linguagem: sem Java-ismos, `record` para dados, funções top-level para
  lógica, `package` + `import` para dividir arquivos (ver `docs/LINGUAGEM.md`).

## Estrutura

```
src/
  main.kf            ponto de entrada: argumentos, configuração, laço do app
  core/              motor do TUI (tela, entrada, sessão, renderização)
    Tema.kf          tokens do design system convertidos para ANSI
    Tela.kf          abstração de tela: cúpula, layout, navegação
    Entrada.kf       leitura de linha, atalhos, menus numerados
    Sessao.kf        sessão autenticada (token, usuário, refresh)
    Config.kf        configuração persistida (host da API, origem, tema)
    Cliente.kf       HTTP + JSON com os headers que a API exige
    Erros.kf         códigos e mensagens de erro da API
  ui/                componentes visuais reutilizáveis
    Caixa.kf         painéis com borda, cabeçalho
    Lista.kf         listas paginadas com seleção
    Campo.kf         entrada de texto
    Badge.kf         selos, sinais (Hoje, não lidas)
    Menu.kf          menus de navegação e atalhos
  api/               um arquivo por domínio da API do backend
    Feed.kf, Perfil.kf, Mensagens.kf, ...
  screens/           uma tela por área do produto
    Inicio.kf, Entrar.kf, Feed.kf, Post.kf, Perfil.kf, ...
tests/               testes `kof test`
docs/                esta pasta
```

## Camadas

`main.kf` monta a `Sessao` e a `Config`, instancia o `Cliente` e entrega ao laço
de telas. Cada tela recebe `(Sessao, Cliente, Tema)` e devolve a próxima tela. Nada
de estado global escondido: a tela é uma função de renderização + um comando.

## Contrato com a API

Descoberto lendo o backend, não inventado:

- Base: `https://api.enois.ia.br/api` (QA: `https://enois-api-qa.b7cloud.tech/api`).
- **Origem obrigatória**: toda requisição leva `X-Client-Origin` com uma origem
  cadastrada (`https://enois.ia.br`). Sem isso o backend responde
  `ORIGIN_REQUIRED` / `ORIGIN_NOT_ALLOWED`.
- **Escritas** com sessão por cookie exigem `X-CSRF-Protection: 1`.
- O CLI usa o header `X-Session-Token`, que o `SessionCookieFilter` aceita
  explicitamente para clientes não-browser — por isso não é preciso manter um
  cookie jar. O login responde com os cookies `Set-Cookie`; o CLI lê o valor do
  `enois_session` e o reusa no header.
- Envelope de sucesso: JSON puro ou `{body}`. Erro: `{code, message}`.
- Paginação por cursor (`cursor` + `limit`).

## Limites conhecidos do Kof 0.8.0

- Não há raw mode / leitura de tecla única: o TUI é linha a linha (Enter para
  confirmar), com menus numerados e comandos de barra.
- Cores são emitidas manualmente em ANSI (funciona; ver `Tema.kf`).
- `process.env` não lê variáveis (executa programa): configuração vem de
  argumentos de linha de comando e do arquivo em `~/.config/enois/config.json`.
