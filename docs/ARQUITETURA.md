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
  main.kf            ponto de entrada: instancia App
  core/              motor do TUI
    App.kf           laço principal, contextos e navegação
    Ansi.kf          largura, padding, códigos de escape
    Tema.kf          tokens do design system convertidos para ANSI
    Entrada.kf       leitura de linha, menus numerados, confirmação
    Sessao.kf        sessão autenticada (token, usuário, renovação)
    Config.kf        configuração persistida (alvo, origem, estado)
    Cliente.kf       HTTP + JSON com os headers que a API exige
    Resposta.kf      status, corpo e mensagem de erro da API
  ui/                componentes visuais reutilizáveis
    Caixa.kf, Lista.kf, Menu.kf, Campo.kf, Badge.kf
  tipos/             um arquivo por domínio de `src/types/application`
    Feed.kf, Vagas.kf, Carteira.kf, ...
  api/               um arquivo por módulo de `src/lib/api`
    FeedApi.kf, VagasApi.kf, CarteiraApi.kf, ...
  screens/           uma tela por rota do produto
    TelaFeed.kf, TelaVagas.kf, TelaColagem.kf, ...
  tests/             suíte `kof test` (package tests)
build/               saída de `kof build` (ignorada pelo git)
docs/                esta pasta
```

## Rodar testes

Os testes ficam em `src/tests` e precisam da raiz do módulo para resolver os
imports de `api`, `core` e `screens`:

```bash
kof test --module-root src src/tests/unitarios.kf --target jvm
```

A suíte cobre formatação de records, montagem de query string e carga de todas
as telas (o `kof check` não pega `VerifyError` em método compilado; a carga
pega).

## Camadas

`main.kf` só chama `App().executar()`. O `App` monta `Config`, `Sessao` e
`Cliente`, mantém o contexto (social ou profissional) e abre cada tela, que
recebe o `Cliente` — e a `Sessao` quando precisa do usuário logado. Nada de
estado global escondido: a tela é um laço de renderização + comando.

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
