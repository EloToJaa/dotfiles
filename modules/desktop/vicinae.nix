{inputs, ...}: {
  imports = [
    inputs.vicinae.homeManagerModules.default
  ];

  services.vicinae = {
    enable = true;
    autoStart = true;
    useLayerShell = true;

    settings = {
      faviconService = "twenty";
      font = {
        normal = "CaskaydiaCove Nerd Font";
        size = 12;
      };
      popToRootOnClose = true;
      rootSearch = {
        searchFiles = true;
      };
      theme = {
        iconTheme = "Papirus-Dark";
      };
      window = {
        csd = true;
        opacity = 1;
        rounding = 10;
      };
    };
  };
}
