#!/usr/bin/env bash
set -euo pipefail

raiz="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$raiz"

versao="${1:-}"
if [ -z "$versao" ]; then
  versao="$(git describe --tags --abbrev=0 2>/dev/null || echo 0.0.0)"
fi
versao="${versao#v}"

kof_bin="${KOF_BIN:-kof}"
jdk_home="${JAVA_HOME:-$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")}"
saida="build/release"
imagem="$saida/enois-cli-$versao-linux-x86_64"
icone="assets/enois-cli.png"
appimagetool="${APPIMAGETOOL:-}"

echo "==> limpando build de release"
rm -rf "$saida" build/jar build/pacote build/deb build/rpm build/appimage build/runtime build/app
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

echo "==> montando árvore instalável"
raizpkg="build/pacote"
rm -rf "$raizpkg"
mkdir -p "$raizpkg/opt/enois-cli/lib/app" \
  "$raizpkg/usr/bin" \
  "$raizpkg/usr/share/applications" \
  "$raizpkg/usr/share/icons/hicolor/512x512/apps"

cp -r "$imagem/lib/runtime" "$raizpkg/opt/enois-cli/lib/runtime"
cp "$imagem/lib/app/kof-app.jar" "$raizpkg/opt/enois-cli/lib/app/kof-app.jar"
chmod 644 "$raizpkg/opt/enois-cli/lib/app/kof-app.jar"

cat > "$raizpkg/usr/bin/enois-cli" <<'EOF'
#!/bin/sh
exec /opt/enois-cli/lib/runtime/bin/java -Dfile.encoding=UTF-8 --enable-native-access=ALL-UNNAMED -jar /opt/enois-cli/lib/app/kof-app.jar "$@"
EOF
chmod 755 "$raizpkg/usr/bin/enois-cli"

cat > "$raizpkg/usr/share/applications/enois-cli.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Énóis
Comment=Cliente de terminal da rede Énóis
Exec=enois-cli
Icon=enois-cli
Terminal=true
Categories=Network;InstantMessaging;
X-AppImage-Version=$versao
EOF

install -m 644 "$icone" "$raizpkg/usr/share/icons/hicolor/512x512/apps/enois-cli.png"

echo "==> empacotando deb com jvm embarcado"
raizdeb="build/deb/raiz"
rm -rf build/deb
mkdir -p build/deb
cp -a "$raizpkg" "$raizdeb"
mkdir -p "$raizdeb/DEBIAN"

cat > "$raizdeb/DEBIAN/control" <<EOF
Package: enois-cli
Version: $versao
Section: misc
Maintainer: Rede Énóis <dev@enois.ia.br>
Priority: optional
Architecture: amd64
Homepage: https://enois.ia.br
Depends: libc6, libasound2t64, libx11-6, libxau6, libxcb1, libxdmcp6, libxext6, libxi6, libxrender1
Description: Cliente de terminal da rede Énóis
 TUI da rede Énóis com JVM embarcado, sem dependência de Java instalado.
EOF

fakeroot dpkg-deb --build --root-owner-group "$raizdeb" \
  "$saida/enois-cli-$versao-linux-x86_64.deb" > /dev/null

echo "==> empacotando rpm com jvm embarcado"
if command -v rpmbuild > /dev/null 2>&1; then
  raizrpm="build/rpm"
  rm -rf "$raizrpm"
  mkdir -p "$raizrpm/BUILD" "$raizrpm/RPMS" "$raizrpm/SOURCES" "$raizrpm/SPECS" "$raizrpm/SRPMS"
  tar -czf "$raizrpm/SOURCES/payload.tar.gz" -C "$raizpkg" .

  cat > "$raizrpm/SPECS/enois-cli.spec" <<EOF
Name:           enois-cli
Version:        $versao
Release:        1
Summary:        Cliente de terminal da rede Énóis
License:        Proprietary
URL:            https://enois.ia.br
BuildArch:      x86_64
AutoReqProv:    no
Requires:       glibc, libX11, libXext, libXi, libXrender, libxcb, alsa-lib
Source0:        payload.tar.gz

%description
TUI da rede Énóis com JVM embarcado, sem dependência de Java instalado.

%prep

%build

%install
mkdir -p %{buildroot}
tar -xzf %{_sourcedir}/payload.tar.gz -C %{buildroot}

%files
/opt/enois-cli
/usr/bin/enois-cli
/usr/share/applications/enois-cli.desktop
/usr/share/icons/hicolor/512x512/apps/enois-cli.png

%changelog
* Sun Nov 22 2026 Rede Énóis <dev@enois.ia.br> - $versao-1
- Pacote rpm com JVM embarcado.
EOF

  rpmbuild -bb \
    --define "_topdir $PWD/$raizrpm" \
    --define "debug_package %{nil}" \
    "$raizrpm/SPECS/enois-cli.spec" > /dev/null
  cp "$raizrpm/RPMS/x86_64/enois-cli-$versao-1.x86_64.rpm" "$saida/"
else
  echo "    rpmbuild ausente: rpm não gerado"
fi

echo "==> empacotando appimage"
if [ -z "$appimagetool" ] && command -v appimagetool > /dev/null 2>&1; then
  appimagetool="$(command -v appimagetool)"
fi
if [ -n "$appimagetool" ] && [ -x "$appimagetool" ] && command -v mksquashfs > /dev/null 2>&1; then
  appdir="$PWD/build/appimage/AppDir"
  mkdir -p "$appdir"
  cp -a "$imagem/." "$appdir/"
  install -m 644 "$raizpkg/usr/share/applications/enois-cli.desktop" "$appdir/enois-cli.desktop"
  install -m 644 "$icone" "$appdir/enois-cli.png"

  cat > "$appdir/AppRun" <<'EOF'
#!/bin/sh
exec "$APPDIR/bin/enois-cli" "$@"
EOF
  chmod 755 "$appdir/AppRun"

  ARCH=x86_64 APPIMAGE_EXTRACT_AND_RUN=1 "$appimagetool" "$appdir" \
    "$PWD/$saida/enois-cli-$versao-x86_64.AppImage" > /dev/null
else
  echo "    appimagetool ou mksquashfs ausente: AppImage não gerado"
fi

echo "==> tarball"
tar -czf "$saida/enois-cli-$versao-linux-x86_64.tar.gz" -C "$saida" \
  "enois-cli-$versao-linux-x86_64"

echo "==> checksums"
(
  cd "$saida"
  rm -f SHA256SUMS.txt
  for pacote in *.jar *.deb *.rpm *.tar.gz *.AppImage; do
    [ -f "$pacote" ] && sha256sum "$pacote"
  done > SHA256SUMS.txt
)

echo "==> artefatos"
ls -la "$saida"
