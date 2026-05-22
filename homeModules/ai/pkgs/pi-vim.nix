{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "pi-vim";
  version = "unstable-2026-05-22";

  src = fetchFromGitHub {
    owner = "lajarre";
    repo = "pi-vim";
    rev = "651320bdea4d63394e8a09910e955617fe6218de";
    hash = "sha256-vn6oXHeZ8Tog46W4T29jTVf789qPkn4XS/Z6H71I8rA=";
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
