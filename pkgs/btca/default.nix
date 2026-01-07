{
  lib,
  stdenv,
  fetchurl,
  nodejs,
}:
stdenv.mkDerivation rec {
  pname = "btca";
  version = "0.6.42";

  src = fetchurl {
    url = "https://registry.npmjs.org/btca/-/btca-${version}.tgz";
    hash = "sha256-1xf4765bjaknby6s4jrmkpy48m4lia34kpa3zf3w58pqvnskx5ia";
  };

  buildInputs = [nodejs];

  unpackPhase = ''
    tar xf $src
    cd package
  '';

  buildPhase = ''
    export HOME=$(mktemp -d)
    npm install --production
  '';

  installPhase = ''
        mkdir -p $out/bin $out/lib/node_modules/btca
        cp -R . $out/lib/node_modules/btca/
        cat > $out/bin/btca << 'EOF'
    #!/bin/sh
    exec ${nodejs}/bin/node $out/lib/node_modules/btca/bin.js "$@"
    EOF
        chmod +x $out/bin/btca
  '';

  meta = with lib; {
    description = "CLI tool for asking questions about technologies using OpenCode";
    homepage = "https://btca.dev";
    license = licenses.mit;
    platforms = platforms.unix;
    mainProgram = "btca";
  };
}
