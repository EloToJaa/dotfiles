{pkgs, ...}: {
  home.packages = with pkgs; [
    leetcode-cli
  ];

  home.file.".leetcode/leetcode.toml".text = ''
    [code]
    editor = "nvim"
    lang = "cpp"
    comment_leading = "//"
    comment_problem_desc = true
    test = true
    inject_before = ["#include<bits/stdc++.h>", "using namespace std;"]
    inject_after = ["int main() {\n  Solution solution;\n\n}"]

    [storage]
    cache = 'Problems'
    code = 'code'
    root = '~/.leetcode'
    scripts = 'scripts'
  '';
}
