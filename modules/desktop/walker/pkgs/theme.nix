{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "walker-catppuccin";
  version = "unstable-2025-09-06";

  src = fetchFromGitHub {
    owner = "Krymancer";
    repo = "walker";
    rev = "15ad25fc3ad5496094ece50300da2ac6bc355efe";
    hash = "sha256-Fqh6/GEn2y7N5IBLSnva5djzADqpivIE321EREtpCSE=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/themes/* $out
  '';

  meta = with lib; {
    description = "Catpuccin themes for walker";
    homepage = "https://github.com/Krymancer/walker";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
