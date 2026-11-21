{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "anthropics-skills";
  version = "0-unstable-2026-11-16";

  src = fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = "e4bb5d960d87126ff3b3a8af1a104b7db67560ba";
    hash = "sha256-Gr9LatjawHHK9uKpoclWoiDHZ0NTpP3/4Pmeatl8p/Q=";
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
