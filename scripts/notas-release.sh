#!/usr/bin/env bash
set -euo pipefail

versao="${1:-}"
if [ -z "$versao" ]; then
  versao="$(git describe --tags --abbrev=0 2>/dev/null || echo 0.0.0)"
fi
versao="${versao#v}"

raiz="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$raiz"

cat <<EOF
Cliente de terminal do Énóis, feito em Kof, com a identidade do design system.

## Pacotes

Todos os pacotes de Linux já vêm com a **JVM embarcada**: não precisa ter Java instalado.

| Arquivo | O que é | Como instalar |
|---|---|---|
| \`enois-cli-$versao-linux-x86_64.deb\` | Debian/Ubuntu | \`sudo dpkg -i enois-cli-$versao-linux-x86_64.deb\` |
| \`enois-cli-$versao-1.x86_64.rpm\` | Fedora/RHEL/openSUSE | \`sudo rpm -Uvh enois-cli-$versao-1.x86_64.rpm\` |
| \`enois-cli-$versao-x86_64.AppImage\` | Arquivo único, sem instalação | \`chmod +x\` e executar |
| \`enois-cli-$versao-linux-x86_64.tar.gz\` | App-image portátil | Extrair e rodar \`bin/enois-cli\` |
| \`enois-cli-$versao.jar\` | Fat jar | Precisa de JVM 25+ |

O \`.deb\` e o \`.rpm\` instalam em \`/opt/enois-cli\`, criam o comando \`enois-cli\` em \`/usr/bin\`, a entrada de área de trabalho e o ícone do Énóis.

\`\`\`bash
# depois de instalar o deb ou o rpm
enois-cli
\`\`\`

\`\`\`bash
# app-image portátil
tar -xzf enois-cli-$versao-linux-x86_64.tar.gz
./enois-cli-$versao-linux-x86_64/bin/enois-cli
\`\`\`

\`\`\`bash
# AppImage
chmod +x enois-cli-$versao-x86_64.AppImage
./enois-cli-$versao-x86_64.AppImage
\`\`\`

\`\`\`bash
# jar
java --enable-native-access=ALL-UNNAMED -jar enois-cli-$versao.jar
\`\`\`
EOF

if [ -f build/release/SHA256SUMS.txt ]; then
  echo
  echo "## Conferir o download"
  echo
  echo '```bash'
  echo "sha256sum -c SHA256SUMS.txt"
  echo '```'
  echo
  echo '```'
  cat build/release/SHA256SUMS.txt
  echo '```'
fi

cat <<'EOF'

## Requisitos

- Linux x86_64 para o `.deb`, o `.rpm`, o `.tar.gz` e o AppImage; o jar roda em qualquer JVM 25+.
- Terminal UTF-8. Imagens aparecem no Kitty, WezTerm, Ghostty, iTerm2, foot, mlterm, contour e mintty; nos demais, a galeria abre o arquivo no visualizador do sistema.

## Limitações conhecidas

- As chamadas HTTP são síncronas: publicar ou anexar uma imagem segura o teclado até a resposta do servidor.
- O envio de mídia depende de o servidor devolver `provider = S3`; durante a migração de armazenamento a interface mostra o aviso e não finge sucesso.
EOF
