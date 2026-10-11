{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "agent-browser-skills";
  version = "0.39.0-unstable-2026-10-11";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    rev = "d9570915f4dd6504dee4070379d2c4f79d81dbb2";
    hash = "sha256-OZ8nKcn0+OqimKlQcUTZxAqzHAHNOKE1L5Cd495iP3o=";
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
