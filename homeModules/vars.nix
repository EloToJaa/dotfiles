{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.settings) username isServer;
  owner = username;
  group = username;
in {
  clan.core.vars.generators = {
    dav = {
      share = true;
      files = {
        passwd = {
          inherit owner group;
          secret = true;
          deploy = false;
        };
      };
      runtimeInputs = with pkgs; [
        pwgen
      ];
      script = ''
        pwgen -s 64 1 > $out/passwd
      '';
    };
    accounts = lib.mkIf (!isServer) {
      share = true;
      files = {
        dav-passwd = {
          inherit owner group;
          secret = true;
          deploy = true;
        };
      };
      dependencies = [
        "dav"
      ];
      script = ''
        cp $in/dav/passwd $out/dav-passwd
      '';
    };
    # borgbackup = lib.mkIf isServer {
    #   files."borgbackup.ssh" = {
    #     inherit owner group;
    #   };
    #   files."borgbackup.repokey" = {
    #     inherit owner group;
    #   };
    # };
  };
}
