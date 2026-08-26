{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "pi-vim";
  version = "unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "lajarre";
    repo = "pi-vim";
    rev = "2671cf114428bd2f04430cd0dfe86ea4f739586d";
    hash = "sha256-VorcGMt3H4hGnbGTGUgTmJuXRK2ud+3ozT4glGX29Do=";
  };

  postPatch = ''
        substituteInPlace clipboard-mirror.ts \
          --replace-fail 'const PI_CODING_AGENT_MODULE_URL = import.meta.resolve(
      "@earendil-works/pi-coding-agent",
    );' 'const PI_CODING_AGENT_MODULE_URL = new URL(
      "package.json",
      `file://''${process.env.PI_PACKAGE_DIR}/`,
    ).href;' \
          --replace-fail 'import { copyToClipboard } from ''${JSON.stringify(PI_CODING_AGENT_MODULE_URL)};

    const chunks = [];' 'import { createRequire } from "node:module";

    const require = createRequire(''${JSON.stringify(PI_CODING_AGENT_MODULE_URL)});
    const clipboard = require("@mariozechner/clipboard");
    const chunks = [];' \
          --replace-fail 'await Promise.resolve(copyToClipboard(Buffer.concat(chunks).toString("utf8")));' 'await clipboard.setText(Buffer.concat(chunks).toString("utf8"));'
  '';

  buildPhase = ''
    mkdir $out
    cp -r ./* $out
  '';

  meta = with lib; {
    description = " Vim mode for Pi";
    homepage = "https://github.com/lajarre/pi-vim";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
