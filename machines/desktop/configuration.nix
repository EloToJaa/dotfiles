{
  config,
  inputs,
  ...
}: let
  inherit (config.settings) username;
in {
  _module.args.host = "desktop";
  modules.shared = {
    btrfs = {
      scrub.enable = true;
      snapshots = {
        enable = true;
        subvolumes.home = "/home";
      };
    };
    cpu.vendor = "amd";
    graphics.vendor = "amd";
  };
  programs.vicinae.input-server.package = config.home-manager.users.${username}.programs.vicinae.package;
  programs.craftapps.enable = true; # links /usr/share/fonts for the artcraft apps' text tools
  imports = [
    inputs.craftapps.nixosModules.default
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
