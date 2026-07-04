{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPypi,
  makeWrapper,
  nodejs,
  pnpm_10,
  pnpmConfigHook,
  fetchPnpmDeps,
  python313,
  nix-update-script,
}: let
  python = python313;
  pythonPackages = python.pkgs;

  plex-api-client = pythonPackages.buildPythonPackage rec {
    pname = "plex-api-client";
    version = "0.34.2";
    pyproject = true;

    src = fetchPypi {
      pname = "plex_api_client";
      inherit version;
      hash = "sha256-XSaXLFuc5+3V9X2jtezJkDppvKJ4E9k3r4R8Y30+2Go=";
    };

    build-system = [pythonPackages.poetry-core];

    dependencies = with pythonPackages; [
      httpcore
      httpx
      pydantic
    ];

    pythonImportsCheck = ["plex_api_client"];
  };

  pythonEnv = python.withPackages (ps:
    [
      plex-api-client
    ]
    ++ (with ps; [
      aiofiles
      bcrypt
      cryptography
      fastapi
      h2
      httptools
      httpx
      msgspec
      packaging
      pydantic
      pydantic-settings
      python-dotenv
      python-multipart
      uvicorn
      uvloop
      watchfiles
      websockets
    ]));
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "musicseerr";
    version = "1.4.2";

    src = fetchFromGitHub {
      owner = "HabiRabbu";
      repo = "MusicSeerr";
      tag = "v${finalAttrs.version}";
      hash = "sha256-LSFf7vHs44Xvc6IKR7ZFR8ENXINQgMeKbtl0FQ9Y3Qs=";
    };

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pnpm_10;
      sourceRoot = "${finalAttrs.src.name}/frontend";
      fetcherVersion = 4;
      hash = "sha256-n+o22hQ4aVBJ4e2cvgRnUbm50MtCiddOEH+lhooqJgY=";
    };

    pnpmRoot = "frontend";

    nativeBuildInputs = [
      makeWrapper
      nodejs
      pnpmConfigHook
      pnpm_10
    ];

    buildPhase = ''
      runHook preBuild

      pushd frontend
      pnpm run build
      popd

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/musicseerr $out/bin
      cp -R backend/. $out/lib/musicseerr
      cp -R frontend/build $out/lib/musicseerr/static
      makeWrapper ${pythonEnv}/bin/uvicorn $out/bin/musicseerr \
        --chdir $out/lib/musicseerr \
        --add-flags "main:app --host 127.0.0.1 --port \''${PORT:-8688} --loop uvloop --http httptools --workers 1"

      runHook postInstall
    '';

    passthru = {
      inherit plex-api-client pythonEnv;
      updateScript = nix-update-script {};
    };

    meta = {
      description = "Self-hosted music request and discovery app built around Lidarr";
      homepage = "https://github.com/HabiRabbu/MusicSeerr";
      changelog = "https://github.com/HabiRabbu/MusicSeerr/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.agpl3Only;
      mainProgram = "musicseerr";
      platforms = lib.platforms.linux;
    };
  })
