{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.modules.desktop.dms-shell;
  inherit (config.home) homeDirectory;
in {
  options.modules.desktop.dms-shell = {
    enable = lib.mkEnableOption "Enable DankMaterialShell";
  };
  config = lib.mkIf cfg.enable {
    programs.dank-material-shell = {
      enable = true;

      niri = {
        enableKeybinds = false;
        enableSpawn = true;

        includes = {
          enable = true;

          override = true;
          originalFileName = "hm";
          filesToInclude = [
            "alttab"
            "colors"
            "cursor"
            "layout"
            "outputs"
            "windowrules"
            "wpblur"
          ];
        };
      };

      # package = pkgs.unstable.dms-shell;
      quickshell.package = pkgs.unstable.quickshell;
      dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;

      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableClipboardPaste = true;
      enableDynamicTheming = true;
      enableSystemMonitoring = true;
      enableVPN = true;

      systemd.enable = false;
    };
    # programs.dsearch = {
    #   enable = false;
    #   config = {
    #     # Server configuration
    #     listen_addr = ":43654";
    #
    #     # Index settings
    #     index_path = "${homeDirectory}/.cache/danksearch/index";
    #     max_file_bytes = 2097152; # 2MB
    #     worker_count = 4;
    #     index_all_files = true;
    #
    #     # Auto-reindex settings
    #     auto_reindex = true;
    #     reindex_interval_hours = 24;
    #
    #     # Text file extensions
    #     text_extensions = [
    #       ".txt"
    #       ".md"
    #       ".go"
    #       ".py"
    #       ".js"
    #       ".ts"
    #       ".jsx"
    #       ".tsx"
    #       ".json"
    #       ".yaml"
    #       ".yml"
    #       ".toml"
    #       ".html"
    #       ".css"
    #       ".rs"
    #       ".nix"
    #     ];
    #
    #     # Index paths configuration
    #     index_paths = [
    #       {
    #         path = "${homeDirectory}/Desktop";
    #         max_depth = 6;
    #         exclude_hidden = true;
    #         exclude_dirs = ["node_modules" "venv" "target"];
    #       }
    #       {
    #         path = "${homeDirectory}/Downloads";
    #         max_depth = 6;
    #         exclude_hidden = true;
    #         exclude_dirs = ["node_modules" "venv" "target"];
    #       }
    #       {
    #         path = "${homeDirectory}/Documents";
    #         max_depth = 6;
    #         exclude_hidden = true;
    #         exclude_dirs = ["node_modules" "venv" "target"];
    #       }
    #       {
    #         path = "${homeDirectory}/Pictures";
    #         max_depth = 6;
    #         exclude_hidden = true;
    #         exclude_dirs = ["node_modules" "venv" "target"];
    #       }
    #       {
    #         path = "${homeDirectory}/Projects";
    #         max_depth = 0;
    #         exclude_hidden = true;
    #         exclude_dirs = ["node_modules" ".git" "target" "dist"];
    #       }
    #       {
    #         path = "${homeDirectory}/.config";
    #         max_depth = 8;
    #         exclude_hidden = true;
    #         exclude_dirs = ["node_modules" ".git" "target" "dist"];
    #       }
    #     ];
    #   };
    # };
  };
}
