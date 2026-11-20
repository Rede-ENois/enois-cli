# enois-cli

Cliente de terminal (TUI) da rede Énóis — as mesmas telas e funcionalidades do
[enois-frontend](https://github.com/Rede-ENois/enois-frontend), em
[linguagem Kof](https://koflang.github.io/).

```
                                              ╭──────────────╮
  ENOIS — o boteco digital do Brasil          │ 1 feed       │
  ──────────────────────────────────────      │ 2 mensagens  │
  @mel · conectado · faísca 12                │ 3 notifica…  │
                                              │ 4 perfil     │
  ── construção civil ─────────────────       │ 5 comunidades│
  » joão · há 5 min                           │ …            │
    hoje o serviço foi pesado                 │              │
    ♥ 3  💬 1                                 ╰──────────────╯
```

## Estado do projeto

A navegação segue a do frontend: os contextos social e profissional, com as
seções você, comunidade, trabalho e explorar. Daí saem feed, mensagens, rede,
salvos, comunidades, grupos, eventos, blogs, par de estudo, vagas, freelances,
serviços, empresas, mentoria, perfil, notificações e conta, além do explorar
(murais, coleções, selos, éroleplay, agenda, moderação, jogos, projetos, loja,
marketplace).

Cada área fala com o contrato real do backend. `src/api` tem um arquivo por
módulo de `src/lib/api` do frontend e `src/tipos` um arquivo por domínio de
`src/types/application`. Detalhes em [docs/ARQUITETURA.md](docs/ARQUITETURA.md).

## Rodar

```bash
kof run src/main.kf --target jvm          # desenvolvimento
kof check src/main.kf                     # tipos
kof test --module-root src src/tests/unitarios.kf --target jvm
kof build src/main.kf --target jvm --fat --output build
java -jar build/kof-app.jar               # distribuído
```

## Licença

GPL-3.0, como o resto da rede.
