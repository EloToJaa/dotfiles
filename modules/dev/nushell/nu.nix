{
  config,
  pkgs,
  variables,
  ...
}: let
  nu_scripts = pkgs.callPackage ../../../pkgs/nu_scripts.nix {};
  nu_catppuccin = pkgs.callPackage ../../../pkgs/nu_catppuccin.nix {};
in {
  programs.nushell = {
    enable = true;
    package = pkgs.nushell;
    environmentVariables = {
      PROMPT_INDICATOR_VI_INSERT = "";
      PROMPT_INDICATOR_VI_NORMAL = "";
      PROMPT_COMMAND = ''""'';
      PROMPT_COMMAND_RIGHT = ''""'';
      NIXPKGS_ALLOW_UNFREE = config.home.sessionVariables.NIXPKGS_ALLOW_UNFREE;
      NIXPKGS_ALLOW_INSECURE = config.home.sessionVariables.NIXPKGS_ALLOW_INSECURE;
      SHELL = "${pkgs.nushell}/bin/nu";
      EDITOR = config.home.sessionVariables.EDITOR;
      VISUAL = config.home.sessionVariables.VISUAL;
      MANPAGER = config.home.sessionVariables.MANPAGER;
      FLAKE = config.home.sessionVariables.FLAKE;
      ANDROID_HOME = config.home.sessionVariables.ANDROID_HOME;
    };
    extraConfig = let
      conf = builtins.toJSON {
        show_banner = false;
        edit_mode = "vi";

        ls.clickable_links = true;
        rm.always_trash = true;

        table = {
          mode = "compact"; # compact thin rounded
          index_mode = "always"; # alway never auto
          header_on_separator = false;
        };

        cursor_shape = {
          vi_insert = "line";
          vi_normal = "block";
        };

        menus = [
          {
            name = "completion_menu";
            only_buffer_difference = false;
            marker = "? ";
            type = {
              layout = "columnar"; # list, description
              columns = 4;
              col_padding = 2;
            };
            style = {
              text = "magenta";
              selected_text = "blue_reverse";
              description_text = "yellow";
            };
          }
        ];
      };
    in ''
      alias pueue = ${pkgs.pueue}/bin/pueue
      alias pueued = ${pkgs.pueue}/bin/pueued
      use ${nu_scripts}/share/nu_scripts/modules/background_task/task.nu
      source ${nu_catppuccin}/share/catppuccin-nushell/themes/catppuccin_${variables.catppuccin.flavor}.nu

      $env.config = ${conf};
    '';
  };
}
