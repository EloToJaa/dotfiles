# This file defines overlays
{inputs, ...}: {
  flake.overlays = {
    # This one brings our custom packages from the 'pkgs' directory
    localPackages = final: _prev: import ./pkgs/pkgs.nix {pkgs = final;};

    # This one contains whatever you want to overlay
    # You can change versions, add patches, set compilation flags, anything really.
    # https://nixos.wiki/wiki/Overlays
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
    };

    # When applied, the unstable nixpkgs set (declared in the flake inputs) will
    # be accessible through 'pkgs.unstable'
    unstablePackages = final: _prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (final.stdenv.hostPlatform) system;
        config.allowUnfree = true;
        config.allowInsecurePredicate = _: true;
      };
      master = import inputs.nixpkgs-master {
        inherit (final.stdenv.hostPlatform) system;
        config.allowUnfree = true;
        config.allowInsecurePredicate = _: true;
      };
    };
  };
}
