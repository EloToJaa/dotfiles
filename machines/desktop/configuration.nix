{
  config,
  inputs,
  ...
}: let
  inherit (config.settings) username;
in {
  _module.args.host = "desktop";
  programs.vicinae.input-server.package = config.home-manager.users.${username}.programs.vicinae.package;
  imports = [
    inputs.srvos.nixosModules.desktop
    inputs.vicinae.nixosModules.default
    ./../../nixosModules/desktop.nix
    ../../homeModules/vars.nix
    {
      home-manager.users.${username}.imports = [
        ../../homeModules/desktop.nix
      ];
    }
  ];
}
