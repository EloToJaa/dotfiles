{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "agent-browser-skills";
  version = "unstable-2026-05-21";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    rev = "4ad284890cb59564af603e6de403dd75dd19e832";
    hash = "sha256-4q3McZ0IbZPKC1GhaKAAfONjsdN1UX0GIMlmyl532L8=";
  };

  buildPhase = ''
    mkdir $out
    cp -r $src/skills/ $out
  '';

  meta = with lib; {
    description = " Browser automation CLI for AI agents Skills";
    homepage = "https://github.com/vercel-labs/agent-browser";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
