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
        laptop.deploy.targetHost = "100.81.29.41";
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

        "users-${username}" = {
          module.name = "users";
          module.input = "clan-core";
          roles.default.tags.nixos = {};
          roles.default.settings = {
            user = username;
            share = true;
          };
        };
      };
    };
  };
}
