{
  pkgs,
  lib,
}:
pkgs.stdenvNoCC.mkDerivation rec {
  pname = "nu_scripts";
  version = "0-unstable-2025-01-03";

  src = pkgs.fetchFromGitHub {
    owner = "nushell";
    repo = pname;
    rev = "66e4845b60d281e86d8917c377ae5341fcf77819";
    hash = "sha256-ICASfyIGI72TkUCuf0H2/y4S9LK5FgFBUNGklpWALKU=";
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
