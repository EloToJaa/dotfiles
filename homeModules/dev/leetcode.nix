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
      gcc
    ];

    programs.zsh.zsh-abbr.abbreviations = shellAliases;

    # Disable to sign in using chrome
    # sops.secrets = {
    #   "leetcode/csrftoken" = {};
    #   "leetcode/session" = {};
    # };
    # [cookies]
    # csrf = "${config.sops.placeholder."leetcode/csrftoken"}"
    # session = "${config.sops.placeholder."leetcode/session"}"
    # site = "leetcode.com"

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

            [storage]
            cache = "problems.db"
            code = "${config.home.homeDirectory}/Projects/leetcode/main"
            root = "~/.leetcode"
            scripts = "${config.home.homeDirectory}/Projects/leetcode/main/scripts"
          '';
        path = "${config.home.homeDirectory}/.leetcode/leetcode.toml";
      };
    };
  };
}
