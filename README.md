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

A TUI cobre as áreas do frontend: feed, perfil, mensagens, notificações,
explorar (busca, comunidades, grupos, eventos, coleções), social (jogos,
roleplay, blogs, murais, desafios, papo reto, empresas, projetos, selos),
trabalho (vagas, freelas, serviços, mentoria, agenda), economia (carteira,
loja, marketplace) e conta (preferências, avisos, moderação).

Cada área fala com o contrato real do backend — os `record` em `src/api/Tipos*`
espelham os DTOs. Detalhes em [docs/ARQUITETURA.md](docs/ARQUITETURA.md).

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
