{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "mattpocock-skills";
  version = "unstable-2026-05-28";

  src = fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "0288510dd61ff6ef7c2003834082ab8f2387e80e";
    hash = "sha256-XVT4fggiumXwGBO74JbscqMjHIUCMr3rAH0/ZXvBc5s=";
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
