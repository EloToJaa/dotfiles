{
  pkgs,
  config,
  lib,
  ...
}: let
  shellAliases = {
    lc = "leetcode";
  };
  cfg = config.modules.dev.leetcode;
in {
  options.modules.dev.leetcode = {
    enable = lib.mkEnableOption "Enable leetcode module";
  };
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      leetcode-cli
    ];

    programs = {
      zsh.shellAliases = shellAliases;
    };

    sops.secrets = {
      "leetcode/csrftoken" = {};
      "leetcode/session" = {};
    };

    sops.templates = {
      "leetcode.toml" = {
        content =
          /*
          toml
          */
          ''
            [code]
            editor = "nvim"
            lang = "cpp"
            comment_leading = "//"
            comment_problem_desc = true
            test = true
            inject_before = ["#include<bits/stdc++.h>\n", "using namespace std;\n"]
            inject_after = [""]

            [cookies]
            csrf = "${config.sops.placeholder."leetcode/csrftoken"}"
            session = "${config.sops.placeholder."leetcode/session"}"
            site = "leetcode.com"

            [storage]
            cache = "problems.db"
            code = "${config.home.homeDirectory}/Projects/leetcode"
            root = "~/.leetcode"
            scripts = "${config.home.homeDirectory}/Projects/leetcode/scripts"
          '';
        path = "${config.home.homeDirectory}/.leetcode/leetcode.toml";
      };
    };
  };
}
