{
  config,
  pkgs,
  ...
}: let
  inherit (config.settings) username;
  owner = username;
  group = username;
in {
  clan.core.vars.generators.accounts = {
    files.dav-passwd = {
      inherit owner group;
      share = true;
      secret = true;
      deploy = true;
    };
    runtimeInputs = with pkgs; [
      pwgen
    ];
    script = ''
      pwgen -s 64 1 > $out/dav-passwd
    '';
  };
}
