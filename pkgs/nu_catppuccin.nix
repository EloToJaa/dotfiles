{
  pkgs,
  lib,
}:
pkgs.stdenvNoCC.mkDerivation rec {
  pname = "nushell";
  version = "0-unstable-2025-04-01";

  src = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = pname;
    rev = "82c31124b39294c722f5853cf94edc01ad5ddf34";
    hash = "sha256-O95OrdF9UA5xid1UlXzqrgZqw3fBpTChUDmyExmD2i4=";
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
