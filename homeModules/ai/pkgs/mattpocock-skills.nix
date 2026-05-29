{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "mattpocock-skills";
  version = "unstable-2026-05-29";

  src = fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "e3b90b5238f38cdea5996e16861dcae28ef52eda";
    hash = "sha256-RRVV4V4h/9GkwnHU4G4PLQtwdU1Lm4istvGncwmQ9dg=";
  };

  buildPhase = ''
    mkdir $out
    cp -r $src/* $out
  '';

  meta = with lib; {
    description = "Skills for Real Engineers.";
    homepage = "https://github.com/mattpocock/skills";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
