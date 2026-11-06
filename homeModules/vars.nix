{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.settings) username isServer;
  owner = username;
  group = username;
  hm = config.home-manager.users.${username};
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
    aoc = lib.mkIf hm.modules.dev.aoc.enable {
      share = true;
      prompts.session = {
        description = "Advent of Code session cookie";
        type = "hidden";
        persist = true;
      };
      files.session = {inherit owner group;};
    };
  };
}
