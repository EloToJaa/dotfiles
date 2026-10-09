{
  lib,
  outputs,
  ...
}: let
  builder_key = outputs.nixosConfigurations.hbox.config.clan.core.vars.generators.nix-builder-ssh.files.public-key;
in {
  imports = [../../nixosModules/server.nix];

  modules.shared.nix-builder.server = {
    enable = true;
    authorizedKeys = lib.optional builder_key.exists builder_key.value;
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 8 * 1024;
    }
  ];
}
