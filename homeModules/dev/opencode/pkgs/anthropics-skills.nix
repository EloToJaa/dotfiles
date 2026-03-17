{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "anthropics-skills";
  version = "unstable-2026-03-17";

  src = fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "b0cbd3df1533b396d281a6886d5132f623393a9c";
    hash = "sha256-GzNpraXV85qUwyGs5XDe0zHYr2AazqFppWtH9JvO3QE=";
  };

  buildPhase = ''
    mkdir $out
    cp -r $src/* $out
  '';

  meta = with lib; {
    description = "Public repository for Agent Skills";
    homepage = "https://github.com/anthropics/skills";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
