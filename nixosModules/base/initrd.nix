{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.base.initrd;
  authorizedKey = config.settings.ssh.keys.user;
  hostKey = config.clan.core.vars.generators.initrd-ssh.files.ssh_host_ed25519_key;
  askAgentName = "systemd-tty-ask-password-agent";
  askAgent = lib.getExe' config.boot.initrd.systemd.package askAgentName;
in {
  options.modules.base.initrd = {
    enable = lib.mkEnableOption "SSH access in the initrd for remote disk unlock";
    kernelModules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Extra network drivers for initrd access; facter-detected drivers are included automatically.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 7172;
    };
  };
  config = lib.mkIf (config.modules.base.enable && cfg.enable) {
    clan.core.vars.generators.initrd-ssh = {
      files.ssh_host_ed25519_key.neededFor = "activation";
      files."ssh_host_ed25519_key.pub".secret = false;
      runtimeInputs = [pkgs.openssh];
      script = ''
        ssh-keygen -t ed25519 -N "" -C "" -f "$out/ssh_host_ed25519_key"
      '';
    };

    boot.initrd = {
      systemd = {
        enable = true;
        # logging in over SSH prompts for the pending disk passphrases
        extraBin.${askAgentName} = askAgent;
        users.root.shell = "/bin/${askAgentName}";
      };

      network = {
        enable = true;

        ssh = {
          inherit (cfg) port;
          enable = true;
          authorizedKeys = [authorizedKey];
          hostKeys = [hostKey.path];
        };
      };

      inherit (cfg) kernelModules;
    };
  };
}
