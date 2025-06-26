{
  pkgs,
  lib,
}:
pkgs.stdenvNoCC.mkDerivation rec {
  pname = "nushell";
  version = "unstable-2025-06-26";

  src = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "nushell";
    rev = "05987d258cb765a881ee1f2f2b65276c8b379658";
    hash = "sha256-tQ3Br6PaLBUNIXY56nDjPkthzvgEsNzOp2gHDkZVQo0=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/catppuccin-nushell
    mv ./* $out/share/catppuccin-nushell

    runHook postInstall
  '';

  passthru.updateScript = pkgs.unstableGitUpdater {};

  meta = {
    description = "A collection of catppuccin themes for nushell";
    homepage = "https://github.com/NikitaRevenco/catppuccin-nushell";
    license = lib.licenses.free;

    platforms = lib.platforms.unix;
    maintainers = [lib.maintainers.CardboardTurkey];
  };
}
