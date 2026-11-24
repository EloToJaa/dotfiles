{
  imports = [
    ./../../nixosModules/server.nix
  ];
  modules.homelab = {
    alloy.enable = true;
    enable = true;
    blocky.enable = true;
    nginx.enable = true;
    home-assistant.enable = true;
    jellyfin = {
      enable = true;
      openFirewall = true;
    };
    share.enable = true;
    postgres = {
      enable = true;
      pgadmin.enable = true;
    };
  };
}
