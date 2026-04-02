{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.desktop.waypaper;
in {
  options.modules.desktop.waypaper = {
    enable = lib.mkEnableOption "Enable waypaper";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      waypaper
      awww
    ];

    xdg.configFile."waypaper/config.ini".text =
      /*
      toml
      */
      ''
        [Settings]
        language = en
        folder = ~/Pictures/wallpapers/others
        monitors = All
        wallpaper = ~/Pictures/wallpapers/wallpaper
        backend = swww
        fill = fill
        sort = name
        color = #ffffff
        subfolders = False
        show_hidden = False
        show_gifs_only = False
        post_command = pkill .waypaper-wrap && wall-change $wallpaper
        number_of_columns = 3
        awww_transition_type = any
        awww_transition_step = 90
        awww_transition_angle = 0
        awww_transition_duration = 2
        awww_transition_fps = 60
        use_xdg_state = False
      '';
  };
}
