# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = _final: prev: {
    jellyfin-web = prev.unstable.jellyfin-web.overrideAttrs {
      installPhase = ''
        runHook preInstall

        # this is the important line
        sed -i "s#</head>#<script src=\"configurationpage?name=skip-intro-button.js\"></script></head>#" dist/index.html

        mkdir -p $out/share
        cp -a dist $out/share/jellyfin-web

        runHook postInstall
      '';
    };

    # https://github.com/tailscale/tailscale/issues/16966#issuecomment-3239543750
    tailscale = prev.unstable.tailscale.overrideAttrs (old: {
      checkFlags =
        builtins.map (
          flag:
            if prev.lib.hasPrefix "-skip=" flag
            then flag + "|^TestGetList$|^TestIgnoreLocallyBoundPorts$|^TestPoller$"
            else flag
        )
        old.checkFlags;
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
      config.allowInsecurePredicate = _: true;
    };
  };
}
