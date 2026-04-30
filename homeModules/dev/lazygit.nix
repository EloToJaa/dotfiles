{
  pkgs,
  lib,
  config,
  ...
}: let
  shellAliases = {
    lg = "lazygit";
  };
  cfg = config.modules.dev.lazygit;
in {
  options.modules.dev.lazygit = {
    enable = lib.mkEnableOption "Enable lazygit";
  };
  config = lib.mkIf cfg.enable {
    programs.lazygit = {
      enable = true;
      package = pkgs.unstable.lazygit;
      settings = {
        keybinding.universal = {
          jumpToBlock = ["1" "2" "3" "4" "6"];
          focusMainView = "5";
        };
        git = {
          log.order = "default";
          parseEmoji = true;
          overrideGpg = true;
          pagers = [
            {
              colorArg = "always";
              pager = "delta --dark --paging=never";
            }
          ];
        };
        update.method = "never";
        gui = {
          border = "single";
          switchTabsWithPanelJumpKeys = true;
          showBranchCommitHash = false;
          theme = {
            activeBorderColor = ["#89b4fa" "bold"];
            inactiveBorderColor = ["#a6adc8"];
            optionsTextColor = ["#89b4fa"];
            selectedLineBgColor = ["#313244"];
            cherryPickedCommitBgColor = ["#45475a"];
            cherryPickedCommitFgColor = ["#89b4fa"];
            unstagedChangesColor = ["#f38ba8"];
            defaultFgColor = ["#cdd6f4"];
            searchingActiveBorderColor = ["#f9e2af"];
          };
          authorColors."*" = "#b4befe";
        };
        disableStartupPopups = true;
        os = {
          open = "xdg-open {{filename}}";
          openLink = "xdg-open {{link}}";
        };
      };
    };

    catppuccin.lazygit = {
      enable = false;
    };

    programs.zsh.zsh-abbr.abbreviations = shellAliases;
  };
}
