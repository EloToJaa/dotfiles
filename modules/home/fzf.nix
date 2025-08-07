{
  variables,
  pkgs,
  ...
}: {
  programs.fzf = {
    enable = true;
    package = pkgs.unstable.fzf;
    enableZshIntegration = true;

    defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
    fileWidgetOptions = ["--preview 'if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'"];
    changeDirWidgetCommand = "fd --type=d --hidden --strip-cwd-prefix --exclude .git";
    changeDirWidgetOptions = ["--preview 'eza --tree --color=always {} | head -200'"];
  };
  catppuccin.fzf = {
    enable = true;
    flavor = variables.catppuccin.flavor;
    accent = variables.catppuccin.accent;
  };
}
