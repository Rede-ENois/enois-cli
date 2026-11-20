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

Em construção — planejamento e núcleo em andamento na branch `feat/tui-kof`.
Acompanhe o plano em [docs/ARQUITETURA.md](docs/ARQUITETURA.md) e o índice de
telas em [docs/TELAS.md](docs/TELAS.md).

## Rodar

```bash
kof run src/main.kf --target jvm          # desenvolvimento
kof build src/main.kf --target jvm --fat --output build
java -jar build/kof-app.jar               # distribuído
```

## Licença

GPL-3.0, como o resto da rede.
