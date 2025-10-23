{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (config.settings) username;
  cfg = config.modules.base;
in {
  config = lib.mkIf cfg.enable {
    # Create symlink to /bin/bash
    # - https://github.com/lima-vm/lima/issues/2110
    systemd = {
      extraConfig = "DefaultTimeoutStopSec=10s";
      tmpfiles.rules = [
        "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
        "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
        "d /var/lib/private/sops/age 0755 root root"
      ];
    };
  };
}
