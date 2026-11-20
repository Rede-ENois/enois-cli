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

## Releases

Cada release publica três artefatos:

| Artefato | Para quê |
|---|---|
| `enois-cli-<v>.jar` | rodar com `java -jar`, exige JDK 25 |
| `enois-cli-<v>-linux-x86_64.deb` | instalar no Debian/Ubuntu, com JVM embarcado |
| `enois-cli-<v>-linux-x86_64.tar.gz` | app autocontido, extrair e rodar `bin/enois-cli` |

O `.deb` e o tarball trazem o runtime embarcado: instalar o pacote e usar
`enois-cli` no PATH, sem Java na máquina.

```bash
bash scripts/release.sh 0.1.0            # gera os artefatos em build/release
```

Publicar é por tag: `git tag v0.1.0 && git push origin v0.1.0` dispara
`.github/workflows/release.yml`, que checa os tipos, roda os testes, empacota e
anexa os artefatos na release do GitHub.

## Licença

GPL-3.0, como o resto da rede.
