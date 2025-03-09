{
  pkgs,
  config,
  ...
}: let
  shellAliases = {
    lc = "leetcode";
  };
in {
  home.packages = with pkgs; [
    leetcode-cli
    aoc-cli
  ];

  programs = {
    zsh.shellAliases = shellAliases;
    nushell.shellAliases = shellAliases;
  };

  sops.templates = {
    "leetcode.toml" = {
      content = ''
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
    "adventofcode.session" = {
      content = "${config.sops.placeholder."aoc/session"}";
      path = "${config.home.homeDirectory}/.config/adventofcode.session";
    };
  };
}
