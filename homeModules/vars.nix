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
  clan.core.vars.generators.dav = {
    files.passwd = {
      share = true;
      secret = true;
      deploy = false;
    };
    runtimeInputs = with pkgs; [
      pwgen
    ];
    script = ''
      pwgen -s 64 1 > $out/passwd
    '';
  };
  clan.core.vars.generators.accounts = lib.mkIf (!isServer) {
    files.dav-passwd = {
      inherit owner group;
      share = true;
      secret = true;
      deploy = true;
    };
    dependencies = [
      "dav"
    ];
    script = ''
      cp $in/dav/passwd $out/dav-passwd
    '';
  };
}
