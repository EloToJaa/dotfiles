{
  pkgs,
  lib,
}:
pkgs.stdenvNoCC.mkDerivation rec {
  pname = "nu_scripts";
  version = "0-unstable-2025-04-01";

  src = pkgs.fetchFromGitHub {
    owner = "nushell";
    repo = pname;
    rev = "a19339cdaa94db45206d0656ccad57020b4830c9";
    hash = "sha256-l96wciWs4HVIMpbAWUr5fbcdKcGFOzkmBDGtad7/xd4=";
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
