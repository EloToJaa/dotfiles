{
  pkgs,
  lib,
}:
pkgs.stdenvNoCC.mkDerivation rec {
  pname = "catppuccin-nushell";
  version = "0-unstable-2025-01-03";

  src = pkgs.fetchFromGitHub {
    owner = "NikitaRevenco";
    repo = pname;
    rev = "10a429db05e74787b12766652dc2f5478da43b6f";
    hash = "sha256-7XfoWsrMRGefc3ygxixUqAOfkg2ssj7o60Gi74S2lXw=";
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
