{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zsh-auto-notify";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "MichaelAquilina";
    repo = "zsh-auto-notify";
    rev = finalAttrs.version;
    hash = "sha256-1+HD4rerEu0uu4hWtMORBeAJJgIgXv65McnqOpaSIV8=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 auto-notify.plugin.zsh -t $out/share/zsh/zsh-auto-notify

    runHook postInstall
  '';

  meta = {
    description = "Desktop notifications for long running zsh commands";
    homepage = "https://github.com/MichaelAquilina/zsh-auto-notify";
    license = lib.licenses.gpl3Only;
    maintainers = [];
    platforms = lib.platforms.all;
  };
})
