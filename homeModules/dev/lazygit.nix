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
      package = pkgs.lazygit;
      settings = {
        keybinding.universal = {
          jumpToBlock = ["1" "2" "3" "4" "6"];
          focusMainView = "5";
        };
        git = {
          log.order = "default";
          parseEmoji = true;
          overrideGpg = true;
          diffRenderers = [
            {
              colorArg = "always";
              command = "delta --dark --paging=never"; # --tabs 2
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
            authorColors."*" = "#b4befe";
          };
        };
        customCommands = [
          {
            key = "E";
            description = "Add empty commit";
            context = "commits";
            command = "git commit --allow-empty -m 'empty commit'";
            loadingText = "Committing empty commit...";
          }
          {
            key = "f";
            command = "git difftool -y {{.SelectedLocalCommit.Sha}} -- {{.SelectedCommitFile.Name}}";
            context = "commitFiles";
            description = "Compare (difftool) with local copy";
          }
          {
            key = "<c-c>";
            description = "commit as non-default author";
            command = ''git commit -m "{{index .PromptResponses 0}}" --author="{{index .PromptResponses 1}} <{{index .PromptResponses 2}}>"'';
            context = "files";
            prompts = [
              {
                type = "input";
                title = "Commit Message";
                initialValue = "";
              }
              {
                type = "input";
                title = "Author Name";
                initialValue = "";
              }
              {
                type = "input";
                title = "Email Address";
                initialValue = "";
              }
            ];
            loadingText = "commiting";
          }
        ];
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
