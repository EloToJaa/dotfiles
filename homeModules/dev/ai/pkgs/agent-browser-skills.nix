{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "agent-browser-skills";
  version = "unstable-2026-04-22";

  src = fetchFromGitHub {
    owner = "vercel-labs";
    repo = "agent-browser";
    rev = "57405f93614fae46e5c955ce662b4785283e1301";
    hash = "sha256-DmlTsY0qYDmJrVUNLLe+FTkstmTdnmLAeXa0lu7fkto=";
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
