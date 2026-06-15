{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  unzip,
  icu,
  openssl,
  zlib,
  nix-update-script,
}: let
  platform = builtins.getAttr stdenv.hostPlatform.system {
    x86_64-linux = {
      suffix = "linux-amd64";
      hash = "sha256-x+Z14bDF2B04fXgBsR/ncsDFyq+FSr/Y8AhGJ2FQ7As=";
    };
    aarch64-linux = {
      suffix = "linux-arm64";
      hash = "sha256-IZofgt8BSpvVWwF0JaUPwNcNJpzGA4lxFqXznYcBzrk=";
    };
  };
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "cleanuparr";
    version = "2.9.13";

    src = fetchurl {
      url = "https://github.com/Cleanuparr/Cleanuparr/releases/download/v${finalAttrs.version}/Cleanuparr-${finalAttrs.version}-${platform.suffix}.zip";
      hash = platform.hash;
    };

    sourceRoot = "Cleanuparr-${finalAttrs.version}-${platform.suffix}";

    dontStrip = true;

    nativeBuildInputs = [
      autoPatchelfHook
      makeWrapper
      unzip
    ];

    buildInputs = [
      icu
      openssl
      zlib
    ];
    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/cleanuparr $out/bin
      cp -R . $out/lib/cleanuparr
      chmod +x $out/lib/cleanuparr/Cleanuparr

      makeWrapper $out/lib/cleanuparr/Cleanuparr $out/bin/cleanuparr \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [icu openssl zlib]}

      runHook postInstall
    '';

    passthru.updateScript = nix-update-script {};

    meta = {
      description = "Advanced download manager for the Servarr ecosystem";
      homepage = "https://github.com/Cleanuparr/Cleanuparr";
      changelog = "https://github.com/Cleanuparr/Cleanuparr/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.gpl3Only;
      mainProgram = "cleanuparr";
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
  })
