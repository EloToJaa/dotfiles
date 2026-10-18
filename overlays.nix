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

    # Temporary fix for https://github.com/AvengeMedia/DankMaterialShell/blob/59431869dc14ab1cb2d05bbbf81839d95e4724cd/distro/nix/common.nix#L21
    inherit (python3Packages) vdirsyncer;
    khal = prev.unstable.khal;
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
          khal = prev.callPackage "${inputs.nixpkgs-unstable}/pkgs/by-name/kh/khal/package.nix" {
            inherit python3Packages;
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
