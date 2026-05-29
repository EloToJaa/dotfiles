{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "pi-vim";
  version = "unstable-2026-05-29";

  src = fetchFromGitHub {
    owner = "lajarre";
    repo = "pi-vim";
    rev = "eaf4933074c39e4b5a76d153d218a6b11c5bbe0a";
    hash = "sha256-90nDxqbQYYu/bhyYyVWdoxIzE5lyjw1o26g4nXOp4DI=";
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
