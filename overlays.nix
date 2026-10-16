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
    # Build agent packages against unstable even when the host uses stable nixpkgs.
    llm-agents = final.unstable.llm-agents;
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config.allowUnfree = true;
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
          llm-agents =
            prev.llm-agents
            // {
              # Upstream still names the entry "T3 Code (Alpha)" after the 0.1.0 rename.
              t3code-desktop = prev.symlinkJoin {
                inherit (prev.llm-agents.t3code-desktop) name passthru meta;
                paths = [prev.llm-agents.t3code-desktop];
                postBuild = ''
                  # The upstream package symlinks all of share/, so rebuild it as a real directory.
                  src=$(readlink -f "$out/share")
                  rm "$out/share"
                  mkdir -p "$out/share/applications"
                  for entry in "$src"/*; do
                    [ "$(basename "$entry")" = applications ] || ln -s "$entry" "$out/share/"
                  done
                  sed 's/^Name=T3 Code (Alpha)$/Name=T3 Code (Beta)/' \
                    "$src/applications/t3code.desktop" > "$out/share/applications/t3code.desktop"
                '';
              };
            };
          pythonPackagesExtensions =
            prev.pythonPackagesExtensions
            ++ [
              (_pyFinal: pyPrev: {
                torchcodec = pyPrev.torchcodec.overridePythonAttrs (old: {
                  # FFmpeg's 8 kHz MP3 resampling differs slightly from TorchCodec.
                  # Keep all other encoder comparisons and the rest of the suite.
                  disabledTests =
                    (old.disabledTests or [])
                    ++ prev.lib.concatMap (
                      output:
                        map (
                          channels: "test_audio_against_cli[${output}-mp3-8000-${channels}-asset1]"
                        ) ["None-None" "None-0" "1-None" "1-0"]
                    ) ["to_file" "to_file_like"];
                });
              })
            ];
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
    };
  };
in {
  # For internal use in perSystem
  _module.args.overlaysList = [
    inputs.bun2nix.overlays.default
    inputs.helium.overlays.default
    localPackages
    modifiedPackages
    unstablePackages
  ];

  # For external access via outputs.overlays
  flake.overlays = {
    inherit localPackages modifiedPackages unstablePackages;
    bun2nix = inputs.bun2nix.overlays.default;
    helium = inputs.helium.overlays.default;
  };
}
