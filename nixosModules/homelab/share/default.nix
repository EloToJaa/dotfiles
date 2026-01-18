{
  lib,
  config,
  ...
}: let
  inherit (config.settings) username;
  cfg = config.modules.homelab.share;
in {
  options.modules.homelab.share = {
    enable = lib.mkEnableOption "Enable share";
  };
  config = lib.mkIf cfg.enable {
    services.samba = {
      enable = true;
      openFirewall = true;
      securityType = "user";

      settings = {
        global = {
          workgroup = "WORKGROUP";
          "server string" = "nixos-smb";
          security = "user";

          # macOS compatibility
          "min protocol" = "SMB2";
          "ea support" = "yes";
          "vfs objects" = "catia fruit streams_xattr";
          "fruit:aapl" = "yes";
          "fruit:metadata" = "stream";
          "fruit:resource" = "stream";
          "fruit:encoding" = "native";
        };

        share = {
          path = "/opt/share";
          browseable = "yes";
          "read only" = "no";
          "valid users" = username;
          "force user" = username;
          "force group" = "users";
          "create mask" = "0644";
          "directory mask" = "0755";
        };
      };
    };

    services.samba-wsdd = {
      enable = true; # makes it visible in Finder
      openFirewall = true;
    };
  };
}
