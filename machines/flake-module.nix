{
  inputs,
  self,
  ...
}: {
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
      # tags = {config, ...}: {
      #   backup = builtins.filter (name: name != "blob64" && name != "installer") config.nixos;
      # };

      instances = {
        emergency-access = {
          module.name = "emergency-access";
          module.input = "clan-core";
          roles.default.tags.nixos = {};
        };

        # sshd-mic92 = {
        #   module.name = "sshd";
        #   module.input = "clan-core";
        #   roles.server.tags.nixos = {};
        #   roles.client.tags.nixos = {};
        #   # tor-hidden-service
        #   roles.client.extraModules = [../nixosModules/ssh.nix];
        #   roles.client.settings = {
        #     certificate.searchDomains = [
        #       "i"
        #       "r"
        #       "local"
        #       "onion"
        #       "thalheim.io"
        #     ];
        #   };
        # };

        internet = {
          module.name = "internet";
          module.input = "clan-core";
          # roles.default.machines.laptop = {
          #   settings.host = "laptop.x";
          # };
        };

        # tor.roles.server.tags.nixos = {};

        users-root = {
          module.name = "users";
          module.input = "clan-core";
          roles.default.tags.nixos = {};
          roles.default.settings = {
            user = "root";
            prompt = false;
            groups = [];
          };
        };
      };
    };
  };
}
