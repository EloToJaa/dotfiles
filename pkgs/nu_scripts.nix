{
  pkgs,
  lib,
}:
pkgs.stdenvNoCC.mkDerivation rec {
  version = "unstable-2025-04-22";

  src = pkgs.fetchFromGitHub {
    owner = "nushell";
    repo = "nu_scripts";
    rev = "488b9b0bc3ed15e108c92132bb91ac4e674189e6";
    hash = "sha256-3MmtlRhciugVt3WHijsnK+DEFtIH1LTSA5TJHAsoLY8=";
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
