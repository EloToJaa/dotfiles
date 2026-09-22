# This file defines overlays
{inputs, ...}: let
  # Individual overlay definitions
  localPackages = final: _prev:
    import ./pkgs/pkgs.nix {
      pkgs = final;
      inherit (inputs) pyproject-build-systems pyproject-nix uv2nix yamtrack-src;
    };

  modifiedPackages = _final: prev: let
    python3Packages = prev.python3Packages.overrideScope (
      _pyFinal: pyPrev: {
        click-threading = pyPrev.click-threading.overridePythonAttrs (_old: {
          enabledTestPaths = ["tests"];
        });
      }
    );
  in {
    jellyfin-web = prev.unstable.jellyfin-web.overrideAttrs {
      installPhase = ''
        runHook preInstall

        sed -i "s#</head>#<script src=\"configurationpage?name=skip-intro-button.js\"></script></head>#" dist/index.html

        mkdir -p $out/share
        cp -a dist $out/share/jellyfin-web

        runHook postInstall
      '';
    };

    tailscale = prev.unstable.tailscale.overrideAttrs (old: {
      checkFlags =
        map (
          flag:
            if prev.lib.hasPrefix "-skip=" flag
            then flag + "|^TestGetList$|^TestIgnoreLocallyBoundPorts$|^TestPoller$|^TestBreakWatcherConnRecv$"
            else flag
        )
        old.checkFlags;
    });

    # Temporary fix for https://github.com/AvengeMedia/DankMaterialShell/blob/59431869dc14ab1cb2d05bbbf81839d95e4724cd/distro/nix/common.nix#L21
    inherit (python3Packages) vdirsyncer;
    khal = prev.unstable.khal;

    # karakeep = prev.unstable.karakeep.overrideAttrs {
    #   # Remove the failing patch - Next.js 15 changed the image-optimizer.js file structure
    #   # The patch was trying to allow NEXT_CACHE_DIR env var for cache directory
    #   preInstall = '''';
    # };
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstablePackages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
      config.allowInsecurePredicate = _: true;
      overlays = [
        inputs.llm-agents.overlays.shared-nixpkgs
        (_final: prev: let
          python3Packages = prev.python3Packages.overrideScope (
            _pyFinal: pyPrev: {
              click-threading = pyPrev.click-threading.overridePythonAttrs (_old: {
                enabledTestPaths = ["tests"];
              });
            }
          );
        in {
          inherit (python3Packages) vdirsyncer;
          aquamarine = prev.aquamarine.overrideAttrs (old: {
            # Fix a 0.15.0 null dereference while tearing down multi-output sessions.
            # https://github.com/hyprwm/aquamarine/issues/383
            postPatch =
              (old.postPatch or "")
              + ''
                substituteInPlace src/backend/drm/DRM.cpp \
                  --replace-fail \
                    "if (connector->output && connector->output->asyncCommitEventPending)" \
                    "if (connector && connector->output && connector->output->asyncCommitEventPending)"
              '';
          });
          xwayland-satellite = prev.xwayland-satellite.overrideAttrs (old: {
            # Steam menu popups close immediately with xwayland-satellite 0.8.2.
            patches =
              (old.patches or [])
              ++ [
                (prev.fetchurl {
                  url = "https://github.com/Supreeeme/xwayland-satellite/pull/494.patch";
                  hash = "sha256-ZlQKxBF15yEulODrFjCDDwMzqaqzrLxZEl+867cdBO0=";
                })
              ];
          });
          khal = prev.callPackage "${inputs.nixpkgs-unstable}/pkgs/by-name/kh/khal/package.nix" {
            inherit python3Packages;
          };
          karakeep = prev.karakeep.overrideAttrs {
            # Remove the failing patch - Next.js 15 changed the image-optimizer.js file structure
            preInstall = '''';
          };
          btop = prev.btop.override {rocmSupport = true;};
        })
      ];
    };
    master = import inputs.nixpkgs-master {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
      config.allowInsecurePredicate = _: true;
    };
  };
in {
  # For internal use in perSystem
  _module.args.overlaysList = [
    inputs.bun2nix.overlays.default
    localPackages
    modifiedPackages
    unstablePackages
  ];

  # For external access via outputs.overlays
  flake.overlays = {
    inherit localPackages modifiedPackages unstablePackages;
    bun2nix = inputs.bun2nix.overlays.default;
  };
}
