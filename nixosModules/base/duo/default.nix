{
  lib,
  config,
  ...
}: let
  cfg = config.modules.base.duo;
in {
  options.modules.base.duo = {
    enable = lib.mkEnableOption "Enable duo";
  };

  # TODO: Remove this once the servarr module is fixed https://github.com/NixOS/nixpkgs/pull/486213
  disabledModules = [
    "security/duosec.nix"
  ];
  imports = [
    ./duosec.nix
  ];
  config = lib.mkIf cfg.enable {
    security.duosec = {
      pam.enable = true;
      pushinfo = true;
      autopush = true;
      prompts = 1;
      motd = true;
      host = "api-9400ee3a.duosecurity.com";
      integrationKey = "DIO79X7X7Q1F3FZ1O47G";
      secretKeyFile = config.sops.secrets."duo/key".path;
    };

    sops.secrets = {
      "duo/key" = {};
    };
  };
}
