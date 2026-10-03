{
  config,
  inputs,
  ...
}: let
  inherit (config.settings) username;
in {
  _module.args.host = "laptop";
  modules.shared = {
    cpu.vendor = "amd";
    graphics.vendor = "amd";
  };
  programs.vicinae.input-server.package = config.home-manager.users.${username}.programs.vicinae.package;
  imports = [
    inputs.srvos.nixosModules.desktop
    inputs.vicinae.nixosModules.default
    ./../../nixosModules/laptop.nix
    ../../homeModules/vars.nix
    {
      home-manager.users.${username}.imports = [
        ../../homeModules/laptop.nix
      ];
    }
  ];
  clan.core.deployment.requireExplicitUpdate = true;
}
