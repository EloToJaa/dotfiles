{
  config,
  lib,
  ...
}: let
  cfg = config.modules.base.initrd;
  authorizedKey = config.settings.ssh.keys.user;
in {
  options.modules.base.initrd = {
    enable = lib.mkEnableOption "Enable initrd module";
    kernelModules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Network drivers needed for remote initrd access.";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 7172;
    };
  };
  config = lib.mkIf (config.modules.base.enable && cfg.enable) {
    boot.initrd = {
      systemd = {
        enable = true;
      };

      # uncomment this if you want to be asked for the decryption password on login
      #users.root.shell = "/bin/systemd-tty-ask-password-agent";

      network = {
        enable = true;

        ssh = {
          inherit (cfg) port;
          enable = true;
          authorizedKeys = [authorizedKey];
          hostKeys = [
            "/var/lib/initrd_host_ed25519_key"
            "/var/lib/initrd_host_rsa_key"
          ];
        };
      };
      availableKernelModules = [
        "xhci_pci"
      ];

      inherit (cfg) kernelModules;
    };
  };
}
