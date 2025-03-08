{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    leetcode-cli
  ];

  sops.templates."leetcode.toml" = {
    content = ''
      [code]
      editor = "nvim"
      lang = "cpp"
      comment_leading = "//"
      comment_problem_desc = true
      test = true
      inject_before = ["#include<bits/stdc++.h>", "using namespace std;"]
      inject_after = ["int main() {\n  Solution solution;\n\n}"]

      [cookies]
      csrf = "${config.sops.placeholder."cookies/csrftoken"}"
      session = "${config.sops.placeholder."cookies/session"}"
      site = "leetcode.com"

      [storage]
      cache = "Problems"
      code = "code"
      root = "~/.leetcode"
      scripts = "scripts"
    '';
    path = "${config.home.homeDirectory}/.leetcode/leetcode.toml";
  };
}
