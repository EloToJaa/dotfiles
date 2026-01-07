{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs_25,
  nix-update-script,
  jellyfin,
}:
buildNpmPackage (finalAttrs: {
  pname = "better-context";
  version = "0.6.42";

  src = assert finalAttrs.version == jellyfin.version;
    fetchFromGitHub {
      owner = "davis7dotsh";
      repo = "better-context";
      tag = "v${finalAttrs.version}";
      hash = "sha256-9gDGREPORJILjVqw+Kk56+5qS/TQUd8OFmsEXL7KPAE=";
    };

  nodejs = nodejs_25;

  npmDepsHash = "sha256-AYGWZ5QvmQl8+ayjzkWuBra+QUvde36ReIJ7Fxk89VM=";

  npmBuildScript = ["build:cli"];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -a dist $out/share/jellyfin-web # replace with btca

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "A better way to get up to date context on libraries/technologies in your projects";
    homepage = "https://btca.dev/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      elotoja
    ];
  };
})
