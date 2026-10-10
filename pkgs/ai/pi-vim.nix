{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "pi-vim";
  version = "0.14.2-unstable-2026-09-04";

  src = fetchFromGitHub {
    owner = "lajarre";
    repo = "pi-vim";
    rev = "e55b07c05b648f3bbccf656c2b0c6ec63f1a91d1";
    hash = "sha256-y8qsUKdzAM2yQyNDKWqGBHA139tDDYJlefvT+nVhGKQ=";
  };

  # The extension resolves @earendil-works/pi-coding-agent through
  # import.meta.resolve, which cannot see Pi's package from the store path this
  # derivation installs to, so the module URL comes from PI_PACKAGE_DIR at
  # runtime instead. That URL points at a package.json rather than an entry
  # point, so the clipboard write helper has to reach @mariozechner/clipboard
  # through createRequire, the way upstream's read helper already does.
  postPatch = ''
        substituteInPlace clipboard-mirror.ts \
          --replace-fail '    return import.meta.resolve("@earendil-works/pi-coding-agent");' '    return new URL(
          "package.json",
          `file://''${process.env.PI_PACKAGE_DIR}/`,
        ).href;' \
          --replace-fail 'import { copyToClipboard } from ''${JSON.stringify(moduleUrl)};

    const chunks = [];' 'import { createRequire } from "node:module";

    const require = createRequire(''${JSON.stringify(moduleUrl)});
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
