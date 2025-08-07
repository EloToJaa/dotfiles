{pkgs, ...}: {
  # https://nixos.wiki/wiki/Steam
  programs = {
    steam = {
      enable = true;
      package = pkgs.unstable.steam;

      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false;
      localNetworkGameTransfers.openFirewall = false;

      gamescopeSession.enable = true;

      extraCompatPackages = with pkgs.unstable; [proton-ge-bin];
    };

    gamescope = {
      enable = true;
      package = pkgs.unstable.gamescope;
      capSysNice = true;
      args = [
        "--rt"
        "--expose-wayland"
      ];
    };
  };
  hardware.xone.enable = false; # support for the xbox controller USB dongle
}
