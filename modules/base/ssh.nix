{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (config.settings) username ssh;
  cfg = config.modules.base.ssh;
in {
  options.modules.base.ssh = {
    enable = lib.mkEnableOption "Enable ssh";
    port = lib.mkOption {
      type = lib.types.int;
      default = 22;
      description = "ssh port";
    };
  };
  config = lib.mkIf cfg.enable {
    programs.ssh.package = pkgs.unstable.openssh;
    services.openssh = {
      enable = true;
      ports = [cfg.port];
      settings = {
        PasswordAuthentication = false;
        AllowUsers = null;
        PermitRootLogin = "no";
      };
    };
    users.users.${username}.openssh.authorizedKeys.keys = [
      ssh.keys.user
    ];
    networking.firewall.allowedTCPPorts = [
      cfg.port
    ];
  };
}
