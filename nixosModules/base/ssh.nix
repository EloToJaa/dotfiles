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
    # SSH Certificate Authority (shared)
    clan.core.vars.generators.ssh-ca = {
      share = true;
      files = {
        "ca" = {
          secret = true;
          deploy = false;
        };
        "ca.pub".secret = false;
      };

      runtimeInputs = [pkgs.openssh];
      script = ''
        ssh-keygen -t ed25519 -N "" -f $out/ca
        mv $out/ca.pub $out/ca.pub
      '';
    };

    # Host-specific SSH keys
    clan.core.vars.generators.ssh-host = {
      files = {
        "ssh_host_ed25519_key" = {
          secret = true;
          owner = "root";
          group = "root";
          mode = "0600";
        };
        "ssh_host_ed25519_key.pub".secret = false;
        "ssh_host_ed25519_key-cert.pub".secret = false;
      };

      dependencies = ["ssh-ca"];
      runtimeInputs = [pkgs.openssh];
      script = ''
        # Generate host key
        ssh-keygen -t ed25519 -N "" -f $out/ssh_host_ed25519_key

        # Sign with CA
        ssh-keygen -s $in/ssh-ca/ca \
          -I "host:${config.networking.hostName}" \
          -h \
          -V -5m:+365d \
          $out/ssh_host_ed25519_key.pub
      '';
    };

    programs.ssh.package = pkgs.unstable.openssh;
    services.openssh = {
      enable = true;
      ports = [cfg.port];
      # Configure SSH to use the generated keys
      hostKeys = [
        {
          path = config.clan.core.vars.generators.ssh-host.files."ssh_host_ed25519_key".path;
          type = "ed25519";
        }
      ];
      settings = {
        PasswordAuthentication = false;
        AllowUsers = null;
        PermitRootLogin = "no";
      };
    };
    users.users.${username}.openssh.authorizedKeys.keys = [
      config.clan.core.vars.generators.ssh-host.files."ssh_host_ed25519_key.pub".value
    ];
    networking.firewall.allowedTCPPorts = [
      cfg.port
    ];
  };
}
