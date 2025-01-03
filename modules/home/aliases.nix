{...}: let
  shellAliases = {
    d = "docker";
    ld = "lazydocker";
    dc = "docker compose";
    dcu = "docker compose up -d --force-recreate --remove-orphans";
    dcd = "docker compose down --remove-orphans";

    # Utils
    c = "clear";
    cd = "z";
    tt = "gtrash put";
    s = "sudo";
    cat = "bat";
    diff = "delta --diff-so-fancy --side-by-side";
    less = "bat";
    py = "python";
    ipy = "ipython";
    pdf = "tdf";
    space = "ncdu";
    icat = "wezterm imgcat";
    ssh = "wezterm ssh";

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
  };
in {
  programs = {
    zsh.shellAliases =
      shellAliases
      // {
        dsize = "du -hs";
        open = "xdg-open";
        psv = "source .venv/bin/activate";
        l = "eza --icons -a --group-directories-first -1";
        ll = "eza --icons -a --group-directories-first -1 --long -g";
      };
    nushell.shellAliases =
      shellAliases
      // {
        l = "ls";
        ll = "ls -la";
      };
  };
}
