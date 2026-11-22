#!/usr/bin/env bash
set -euo pipefail

raiz="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$raiz"

versao="${1:-}"
if [ -z "$versao" ]; then
  versao="$(git describe --tags --abbrev=0 2>/dev/null || echo 0.0.0)"
fi

kof_bin="${KOF_BIN:-kof}"
jdk_home="${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")}"
saida="build/release"
imagem="build/release/enois-cli-$versao-linux-x86_64"

echo "==> limpando build de release"
rm -rf "$saida" build/jar build/deb build/runtime build/app
mkdir -p "$saida"

echo "==> checando tipos"
"$kof_bin" check src/main.kf

echo "==> rodando testes"
"$kof_bin" test src/tests/unitarios.kf --module-root src --target jvm

echo "==> compilando jar ($versao)"
"$kof_bin" build src/main.kf --target jvm --fat --release --output build/jar
install -m 644 build/jar/kof-app.jar "$saida/enois-cli-$versao.jar"

echo "==> montando runtime linux embarcado"
"$jdk_home/bin/jlink" \
  --add-modules java.base,java.desktop,java.net.http,java.sql,java.logging,java.naming,java.security.jgss,jdk.crypto.ec \
  --strip-debug --no-header-files --no-man-pages --compress=2 \
  --output build/runtime

echo "==> empacotando app linux"
"$jdk_home/bin/jpackage" \
  --type app-image \
  --name enois-cli \
  --app-version "$versao" \
  --vendor "Rede Énóis" \
  --description "Cliente de terminal da rede Énóis" \
  --input build/jar \
  --main-jar kof-app.jar \
  --main-class Default.Main \
  --runtime-image build/runtime \
  --java-options "-Dfile.encoding=UTF-8" \
  --java-options "--enable-native-access=ALL-UNNAMED" \
  --dest build/app

mv build/app/enois-cli "$imagem"
chmod -R u+rwX,go+rX "$imagem"

echo "==> empacotando deb com jvm embarcado"
raizdeb="build/deb/raiz"
rm -rf build/deb
mkdir -p "$raizdeb/DEBIAN" "$raizdeb/opt/enois-cli/lib/app" "$raizdeb/usr/bin"

cp -r "$imagem/lib/runtime" "$raizdeb/opt/enois-cli/lib/runtime"
cp "$imagem/lib/app/kof-app.jar" "$raizdeb/opt/enois-cli/lib/app/kof-app.jar"
chmod 644 "$raizdeb/opt/enois-cli/lib/app/kof-app.jar"

cat > "$raizdeb/usr/bin/enois-cli" <<'EOF'
#!/bin/sh
exec /opt/enois-cli/lib/runtime/bin/java -Dfile.encoding=UTF-8 --enable-native-access=ALL-UNNAMED -jar /opt/enois-cli/lib/app/kof-app.jar "$@"
EOF
chmod 755 "$raizdeb/usr/bin/enois-cli"

cat > "$raizdeb/DEBIAN/control" <<EOF
Package: enois-cli
Version: $versao
Section: misc
Maintainer: Rede Énóis <dev@enois.ia.br>
Priority: optional
Architecture: amd64
Depends: libc6, libasound2t64, libx11-6, libxau6, libxcb1, libxdmcp6, libxext6, libxi6, libxrender1
Description: Cliente de terminal da rede Énóis
 TUI da rede Énóis com JVM embarcado, sem dependência de Java instalado.
EOF

fakeroot dpkg-deb --build --root-owner-group "$raizdeb" \
  "$saida/enois-cli-$versao-linux-x86_64.deb" > /dev/null

echo "==> tarball"
tar -czf "$saida/enois-cli-$versao-linux-x86_64.tar.gz" -C "$saida" \
  "enois-cli-$versao-linux-x86_64"

echo "==> checksums"
(cd "$saida" && sha256sum *.jar *.deb *.tar.gz > SHA256SUMS.txt)

echo "==> artefatos"
ls -la "$saida"
