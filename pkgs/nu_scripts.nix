{
  pkgs,
  lib,
}:
pkgs.stdenvNoCC.mkDerivation rec {
  pname = "nu_scripts";
  version = "unstable-2025-06-26";

  src = pkgs.fetchFromGitHub {
    owner = "nushell";
    repo = "nu_scripts";
    rev = "156a0110c724ce3a98327190e8a667657e4ed3c1";
    hash = "sha256-O/zqhTFzqhFwCD54iXDfe/9WlqMg2PkiO6TLwUyIxmM=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/nu_scripts
    mv ./* $out/share/nu_scripts

    runHook postInstall
  '';

  passthru.updateScript = pkgs.unstableGitUpdater {};

  meta = {
    description = "Place to share Nushell scripts with each other";
    homepage = "https://github.com/nushell/nu_scripts";
    license = lib.licenses.free;

    platforms = lib.platforms.unix;
    maintainers = [lib.maintainers.CardboardTurkey];
  };
}
