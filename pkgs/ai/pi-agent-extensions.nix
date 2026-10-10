{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "pi-agent-extensions";
  version = "0-unstable-2026-09-22";

  src = fetchFromGitHub {
    owner = "rytswd";
    repo = "pi-agent-extensions";
    rev = "798cf2859c3848bfa175652e00e2784fd98246b2";
    hash = "sha256-qmAihSg/IMvd6b98lKfclY/a2sZe6jEHIInvBB4nBMQ=";
  };

  postPatch = ''
    find . -name '*.ts' -type f -print0 | while IFS= read -r -d $'\0' file; do
      substituteInPlace "$file" \
        --replace-warn '@mariozechner/pi-agent-core' '@earendil-works/pi-agent-core' \
        --replace-warn '@mariozechner/pi-ai' '@earendil-works/pi-ai' \
        --replace-warn '@mariozechner/pi-coding-agent' '@earendil-works/pi-coding-agent' \
        --replace-warn '@mariozechner/pi-tui' '@earendil-works/pi-tui' \
        --replace-warn '@mariozechner/jiti' 'jiti' \
        --replace-warn '@sinclair/typebox' 'typebox'
    done
  '';

  buildPhase = ''
    mkdir $out
    cp -r ./* $out
  '';

  meta = with lib; {
    description = "Pi agent extensions";
    homepage = "https://github.com/rytswd/pi-agent-extensions";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
