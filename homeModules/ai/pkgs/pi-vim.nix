{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "pi-vim";
  version = "unstable-2026-08-19";

  src = fetchFromGitHub {
    owner = "lajarre";
    repo = "pi-vim";
    rev = "2671cf114428bd2f04430cd0dfe86ea4f739586d";
    hash = "sha256-VorcGMt3H4hGnbGTGUgTmJuXRK2ud+3ozT4glGX29Do=";
  };

  buildPhase = ''
    mkdir $out
    cp -r $src/* $out
  '';

  meta = with lib; {
    description = " Vim mode for Pi";
    homepage = "https://github.com/lajarre/pi-vim";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
