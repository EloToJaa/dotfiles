# This file defines overlays
{inputs, ...}: let
  # Individual overlay definitions
  localPackages = final: _prev:
    import ./pkgs/pkgs.nix {
      pkgs = final;
      inherit (inputs) pyproject-build-systems pyproject-nix uv2nix;
      yamtrack-src = inputs.yamtrack;
    };

  modifiedPackages = _final: prev: {
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
    khal = prev.unstable.khal;
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstablePackages = final: _prev: {
    # Build agent packages against unstable even when the host uses stable nixpkgs.
    llm-agents = final.unstable.llm-agents;
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config = {
        allowUnfree = true;
        # gtk2 is marked broken pending removal; omnissa-horizon-client still needs it.
        problems.handlers."gtk+".broken = "warn";
      };
      overlays = [
        inputs.llm-agents.overlays.shared-nixpkgs
        (_final: prev: {
          btop = prev.btop.override {rocmSupport = true;};

          # cargoSetupHook now forces system libraries (RUSTONIG_SYSTEM_LIBONIG,
          # AWS_LC_SYS_USE_SYSTEM), so these packages need them in buildInputs.
          # https://github.com/NixOS/nixpkgs/issues/570938
          aichat = prev.aichat.overrideAttrs (old: {
            buildInputs = (old.buildInputs or []) ++ [prev.oniguruma];
          });
          rqbit = prev.rqbit.overrideAttrs (old: {
            buildInputs = (old.buildInputs or []) ++ [prev.aws-lc];
          });
          rustdesk-flutter = prev.rustdesk-flutter.overrideAttrs (old: {
            buildInputs =
              (old.buildInputs or [])
              ++ (with prev; [libsodium zstd libgit2 zlib]);
          });
          voxtype-vulkan = prev.voxtype-vulkan.overrideAttrs (old: {
            buildInputs = (old.buildInputs or []) ++ [prev.sqlite];
          });
          llm-agents = let
            codex = prev.llm-agents.codex.overrideAttrs (old: {
              buildInputs =
                (old.buildInputs or [])
                ++ (with prev; [aws-lc zstd sqlite zlib rust-jemalloc-sys oniguruma]);
            });
            # The web UI only enables T3 Connect when the Clerk JWT template is baked in
            # alongside the relay URL and publishable key, which the package leaves out.
            t3code-unwrapped = prev.llm-agents.t3code.unwrapped.overrideAttrs (old: {
              env = old.env // {T3CODE_CLERK_JWT_TEMPLATE = "t3-relay";};
            });
            t3code = prev.llm-agents.t3code.override {inherit codex t3code-unwrapped;};
          in
            prev.llm-agents
            // {
              inherit codex t3code;
              t3code-desktop = prev.llm-agents.t3code-desktop.override {inherit t3code;};
            };

          # With structured attrs, sphinx-hook's "$sphinxBuilders" only expands the first
          # array element, so the man builder never runs. Pass the builders as a string.
          khal = prev.khal.overrideAttrs {
            sphinxBuilders = "html man";
          };
          todoman = prev.todoman.overrideAttrs {
            sphinxBuilders = "singlehtml man";
            preInstallSphinx = ''
              rm -rf .sphinx/man/man/_static/
            '';
          };

          pythonPackagesExtensions =
            prev.pythonPackagesExtensions
            ++ [
              (_pyfinal: pyprev: {
                # TypeError message changed upstream: "Expected str, got int".
                pyopenjtalk-plus = pyprev.pyopenjtalk-plus.overrideAttrs (old: {
                  disabledTests =
                    (old.disabledTests or [])
                    ++ ["test_run_njd_from_mecab_invalid_input_should_not_break_next_call"];
                });
                # Timing-based test, flaky on loaded builders.
                ocrmypdf = pyprev.ocrmypdf.overrideAttrs (old: {
                  disabledTests = (old.disabledTests or []) ++ ["test_validation_performance"];
                });
              })
            ];
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
