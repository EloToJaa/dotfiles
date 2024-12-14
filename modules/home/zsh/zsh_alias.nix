{...}: {
  programs.zsh = {
    shellAliases = {
      # Utils
      c = "clear";
      cd = "z";
      tt = "gtrash put";
      s = "sudo";
      cat = "bat";
      code = "codium";
      diff = "delta --diff-so-fancy --side-by-side";
      less = "bat";
      py = "python";
      ipy = "ipython";
      dsize = "du -hs";
      pdf = "tdf";
      open = "xdg-open";
      space = "ncdu";
      icat = "wezterm imgcat";
      ssh = "wezterm ssh";

      l = "eza --icons -a --group-directories-first -1"; #EZA_ICON_SPACING=2
      ll = "eza --icons -a --group-directories-first -1 --long -g";
      tree = "eza --icons --tree --group-directories-first";

      # Nixos
      ns = "nom-shell --run zsh";
      nix-switch = "nh os switch";
      nix-update = "nh os switch --update";
      nix-clean = "nh clean all --keep 5";
      nix-search = "nh search";
      nix-test = "nh os test";
      nix-dev = "nix develop --command zsh";

      # python
      piv = "python -m venv .venv";
      psv = "source .venv/bin/activate";
    };
  };
}
