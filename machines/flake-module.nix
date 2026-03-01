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
        desktop.deploy.targetHost = "${username}@100.87.4.91";
        server.deploy.targetHost = "${username}@100.84.164.91";
      };

      instances = {
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
