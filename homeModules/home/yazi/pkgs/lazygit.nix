{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "yaziPlugins-lazygit";
  version = "unstable-2026-01-28";

  src = fetchFromGitHub {
    owner = "Lil-Dank";
    repo = "lazygit.yazi";
    rev = "0e56060192d1ccd307664bf93b3d0beb1efe528e";
    hash = "sha256-LcEpzSf0E43hnhOxJ/EHNJRk3Au5hcgRZ2Kj412Ykew=";
  };

  buildPhase = ''
    mkdir $out
    cp $src/* $out
  '';

  meta = with lib; {
    description = "Plugin for Yazi to manage git repos with lazygit";
    homepage = "https://github.com/Lil-Dank/lazygit.yazi";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
