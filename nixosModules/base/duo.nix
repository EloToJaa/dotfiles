{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.base.duo;
in {
  options.modules.base.duo = {
    enable = lib.mkEnableOption "Enable duo";
  };
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

    systemd.services.pam-duo = {
      wantedBy = ["sysinit.target"];
      before = [
        "sysinit.target"
        "shutdown.target"
      ];
      conflicts = ["shutdown.target"];
      unitConfig.DefaultDependencies = false;
      script = ''
        if test -f "${cfg.secretKeyFile}"; then
          mkdir -p /etc/duo
          chmod 0755 /etc/duo

          umask 0077
          conf="$(mktemp)"
          {
            cat ${pkgs.writeText "login_duo.conf" configFilePam}
            printf 'skey = %s\n' "$(cat ${cfg.secretKeyFile})"
          } >"$conf"

          mv -fT "$conf" /etc/duo/pam_duo.conf
        fi
      '';
    };

    sops.secrets = {
      "duo/key" = {};
    };
  };
}
