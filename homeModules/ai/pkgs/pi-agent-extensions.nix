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

  buildPhase = ''
    mkdir $out
    cp -r $src/* $out
  '';

  meta = with lib; {
    description = "Pi agent extensions";
    homepage = "https://github.com/rytswd/pi-agent-extensions";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
