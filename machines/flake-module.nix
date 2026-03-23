{
  inputs,
  self,
  config,
  ...
}: let
  inherit (config.settings) username;
in {
  flake.clan = {
    meta = {
      name = "elotoja";
      domain = "elotoja";
      description = "EloToJa's clan";
    };

    specialArgs = {
      inherit inputs;
      outputs = self;
    };

    inventory = {
      machines = {
        laptop.deploy.targetHost = "${username}@100.110.242.103";
        desktop.deploy.targetHost = "${username}@100.112.233.120";
        server.deploy.targetHost = "${username}@192.168.0.32";
      };

      instances = {
        borgbackup = {
          module = {
            name = "borgbackup";
            input = "clan-core";
          };
          roles.client.machines.server.settings = {
            destinations.storagebox = {
              repo = "u441859-sub1@u441859-sub1.your-storagebox.de:/./borgbackup";
              rsh = ''ssh -p 23 -oStrictHostKeyChecking=accept-new -i /run/secrets/vars/borgbackup/borgbackup.ssh'';
            };
            startAt = "*-*-* 03:00:00";
          };
        };

        emergency-access = {
          module.name = "emergency-access";
          module.input = "clan-core";
          roles.default.tags.nixos = {};
        };

        internet = {
          module.name = "internet";
          module.input = "clan-core";
        };

        wifi = {
          module.name = "wifi";
          module.input = "clan-core";
          roles.default = {
            machines.laptop = {
              settings.networks.home = {};
            };
          };
        };

        users-root = {
          module.name = "users";
          module.input = "clan-core";
          roles.default.tags.nixos = {};
          roles.default.settings = {
            user = "root";
            prompt = false;
          };
        };
      };
    };
  };
}
