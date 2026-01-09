{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  nix-update-script,
}: let
  sources = {
    "x86_64-linux" = {
      url = "https://registry.npmjs.org/btca/-/btca-0.6.50.tgz";
      hash = "sha256-4yn95cUqF6/6O2VAJX7GN9VUBz2vAnncoUFhGXY/jy4=";
      binary = "btca-linux-x64";
    };
    "aarch64-linux" = {
      url = "https://registry.npmjs.org/btca/-/btca-0.6.50.tgz";
      hash = "sha256-4yn95cUqF6/6O2VAJX7GN9VUBz2vAnncoUFhGXY/jy4=";
      binary = "btca-linux-arm64";
    };
    "x86_64-darwin" = {
      url = "https://registry.npmjs.org/btca/-/btca-0.6.50.tgz";
      hash = "sha256-4yn95cUqF6/6O2VAJX7GN9VUBz2vAnncoUFhGXY/jy4=";
      binary = "btca-darwin-x64";
    };
    "aarch64-darwin" = {
      url = "https://registry.npmjs.org/btca/-/btca-0.6.50.tgz";
      hash = "sha256-4yn95cUqF6/6O2VAJX7GN9VUBz2vAnncoUFhGXY/jy4=";
      binary = "btca-darwin-arm64";
    };
  };
  source = sources.${stdenvNoCC.hostPlatform.system} or (throw "Unsupported platform: ${stdenvNoCC.hostPlatform.system}");
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "btca";
    version = "0.6.50";

    src = fetchurl {
      url = source.url;
      hash = source.hash;
    };

    nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
      autoPatchelfHook
    ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      cp package/dist/${source.binary} $out/bin/btca
      chmod +x $out/bin/btca

      runHook postInstall
    '';

    passthru.updateScript = nix-update-script {};

    meta = {
      description = "A better way to get up to date context on libraries/technologies in your projects";
      homepage = "https://btca.dev/";
      license = lib.licenses.mit;
      mainProgram = "btca";
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      maintainers = with lib.maintainers; [
        elotoja
      ];
    };
  })
