{
  lib,
  config,
  options,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkMerge mkOption types;
  cfg = config.modules.shared.nix-builder;
  credentials = config.clan.core.vars.generators.nix-builder-ssh.files;
in {
  options.modules.shared.nix-builder = {
    client = {
      enable = mkEnableOption "remote Nix builds with local fallback";
      machines = mkOption {
        type = options.nix.buildMachines.type;
        default = [];
        description = "Remote builders authenticated with this machine's Clan build key.";
      };
      localJobs = mkOption {
        type = types.ints.positive;
        default = 1;
        description = "Local build slots available when remote builders cannot accept a build.";
      };
    };
    server = {
      enable = mkEnableOption "SSH access to the Nix daemon for remote builds";
      authorizedKeys = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "SSH public keys allowed to submit remote Nix builds.";
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.client.enable {
      clan.core.vars.generators.nix-builder-ssh = {
        files = {
          private-key = {};
          public-key = {
            secret = false;
            deploy = false;
          };
        };
        runtimeInputs = [pkgs.openssh];
        script = ''
          ssh-keygen -t ed25519 -N "" -C nix-builder -f "$out/private-key"
          mv "$out/private-key.pub" "$out/public-key"
        '';
      };
    })
    (mkIf cfg.client.enable {
      nix = {
        distributedBuilds = true;
        buildMachines = map (machine: machine // {sshKey = credentials.private-key.path;}) cfg.client.machines;
        settings = {
          builders-use-substitutes = true;
          max-jobs = cfg.client.localJobs;
        };
      };
    })
    (mkIf cfg.server.enable {
      nix.sshServe = {
        enable = true;
        protocol = "ssh-ng";
        write = true;
        trusted = true;
        keys = cfg.server.authorizedKeys;
      };
    })
  ];
}
