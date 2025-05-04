{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-glow";
  version = "unstable-2025-05-04";

  src = fetchFromGitHub {
    owner = "Reledia";
    repo = "glow.yazi";
    rev = "2da96e3ffd9cd9d4dd53e0b2636f83ff69fe9af0";
    hash = "sha256-4krck4U/KWmnl32HWRsblYW/biuqzDPysrEn76buRck=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/* $out
  '';

  meta = with lib; {
    description = "Plugin for Yazi to preview markdown files with glow";
    homepage = "https://github.com/Reledia/glow.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
