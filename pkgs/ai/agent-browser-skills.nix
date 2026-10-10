{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "agent-browser-skills";
  version = "0.39.0-unstable-2026-10-09";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    rev = "44af39842650f0bb9c1afb7354df9a82921d4f09";
    hash = "sha256-8Og2ruMaY+ObT9WiYqCyoXAcwZ/6t2g6SeU3+wF15ck=";
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
