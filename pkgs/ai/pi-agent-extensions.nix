{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "pi-agent-extensions";
  version = "unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "rytswd";
    repo = "pi-agent-extensions";
    rev = "2e7e440e4e87fe875cb02c7c5bad61555d298e7b";
    hash = "sha256-aQslJm88r5vh5PGoCMx0k1CRlnvwhA6ZzSIS52sCX7s=";
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
