{
  lib,
  makeWrapper,
  pkgs,
  pyproject-build-systems,
  pyproject-nix,
  python312,
  stdenvNoCC,
  uv2nix,
  yamtrack-src,
}: let
  workspace = uv2nix.lib.workspace.loadWorkspace {
    workspaceRoot = yamtrack-src;
  };
  pythonSet = (pkgs.callPackage pyproject-nix.build.packages {python = python312;}).overrideScope (
    lib.composeManyExtensions [
      pyproject-build-systems.overlays.default
      (workspace.mkPyprojectOverlay {sourcePreference = "wheel";})
    ]
  );
  venv = pythonSet.mkVirtualEnv "yamtrack-env" workspace.deps.default;
in
  stdenvNoCC.mkDerivation {
    pname = "yamtrack";
    version = "0.26.1";
    src = yamtrack-src;

    nativeBuildInputs = [makeWrapper];

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/yamtrack" "$out/bin"
      cp -R src/. "$out/share/yamtrack"

      substituteInPlace "$out/share/yamtrack/config/settings.py" \
        --replace-fail \
          'Path(BASE_DIR / "db").mkdir(parents=True, exist_ok=True)' \
          'DATA_DIR = Path(config("DATA_DIR", default=BASE_DIR / "db")); DATA_DIR.mkdir(parents=True, exist_ok=True)' \
        --replace-fail \
          '"NAME": BASE_DIR / "db" / "db.sqlite3"' \
          '"NAME": DATA_DIR / "db.sqlite3"'

      DATA_DIR="$TMPDIR/db" SECRET=collectstatic \
        ${venv}/bin/python "$out/share/yamtrack/manage.py" collectstatic --noinput

      makeWrapper ${venv}/bin/python "$out/bin/yamtrack-manage" \
        --chdir "$out/share/yamtrack" \
        --add-flags manage.py
      makeWrapper ${venv}/bin/gunicorn "$out/bin/yamtrack-gunicorn" \
        --chdir "$out/share/yamtrack"
      makeWrapper ${venv}/bin/celery "$out/bin/yamtrack-celery" \
        --chdir "$out/share/yamtrack" \
        --add-flags "--app config"

      runHook postInstall
    '';

    meta = {
      description = "Self-hosted media tracker";
      homepage = "https://github.com/FuzzyGrim/Yamtrack";
      changelog = "https://github.com/FuzzyGrim/Yamtrack/releases/tag/v0.26.1";
      license = lib.licenses.agpl3Only;
      mainProgram = "yamtrack-manage";
      platforms = lib.platforms.linux;
    };
  }
