{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "anthropics-skills";
  version = "0-unstable-2026-11-06";

  src = fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "2c5958ecac7cee2b583967a2c4981d0f4a75c579";
    hash = "sha256-dRCZrNarCCJFuvATgfW6qmwwVS5HGFXNVGOhbVZd7LA=";
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
