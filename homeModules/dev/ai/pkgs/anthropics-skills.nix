{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "anthropics-skills";
  version = "unstable-2026-04-22";

  src = fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "b9e19e6f44773509fbdd7001d77ff41a49a486c1";
    hash = "sha256-qAhHPjh7kgqx0oj8r2SPTPp/BamShae0f/9gbrUePCY=";
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
