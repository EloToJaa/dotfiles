{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: let
  needsreboot = inputs.nixos-needsreboot.packages.${pkgs.stdenv.hostPlatform.system}.default;
  cfg = config.modules.base.bootloader;
in {
  options.modules.base.bootloader = {
    enable = lib.mkEnableOption "Enable bootloader";
  };
  config = lib.mkIf cfg.enable {
    boot = {
      loader = {
        limine = {
          enable = true;
          enableEditor = false;
          maxGenerations = 20;
          secureBoot.enable = true;
        };
        efi.canTouchEfiVariables = true;
      };
      kernel.sysctl = {
        "fs.inotify.max_user_watches" = 1048576;
        "fs.inotify.max_user_instances" = 1024;
        "fs.inotify.max_queued_events" = 32768;
      };

      kernelPackages = pkgs.linuxPackages_latest;
    };

    clan.core.vars.generators.secureboot = {
      files."keys/PK/PK.key".neededFor = "activation";
      files."keys/PK/PK.pem" = {
        secret = false;
        neededFor = "activation";
      };
      files."keys/KEK/KEK.key".neededFor = "activation";
      files."keys/KEK/KEK.pem" = {
        secret = false;
        neededFor = "activation";
      };
      files."keys/db/db.key".neededFor = "activation";
      files."keys/db/db.pem" = {
        secret = false;
        neededFor = "activation";
      };
      runtimeInputs = [pkgs.sbctl];
      script = ''
        sbctl --disable-landlock create-keys
        mv /var/lib/sbctl/keys "$out/keys"
      '';
    };

    systemd.tmpfiles.rules = ["d /var/lib/sbctl 0700 root root -"];
    system.activationScripts.sbctl-keys.text = let
      secureboot_dir = dirOf (dirOf (dirOf config.clan.core.vars.generators.secureboot.files."keys/PK/PK.key".path));
    in ''
      rm -rf /var/lib/sbctl/keys
      install -d -m 0700 /var/lib/sbctl
      cp -a ${secureboot_dir}/keys /var/lib/sbctl/keys
      chmod -R u+rw /var/lib/sbctl/keys
    '';

    systemd.package = pkgs.systemd;

    environment.systemPackages = [
      needsreboot
    ];

    system.activationScripts.nixos-needsreboot = {
      supportsDryActivation = true;
      text = "${
        lib.getExe needsreboot
      } \"$systemConfig\" || true";
    };
    # To prevent getting stuck at shutdown
    systemd.settings.Manager.DefaultTimeoutStopSec = "10s";
  };
}
