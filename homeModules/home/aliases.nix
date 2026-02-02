{
  config,
  lib,
  ...
}: let
  shellAliases = {
    # Utils
    tt = "gtrash put";
    diff = "delta --diff-so-fancy --side-by-side";

    tree = "eza --icons --tree --group-directories-first";

    # Nixos
    nix-switch = "nh os switch";
    nix-upgrade = "nh os switch --update";
    nix-clean = "nh clean all --keep 5";
    nix-search = "nh search";
    nix-test = "nh os test";
  };
  cfg = config.modules.home;
in {
  config = lib.mkIf cfg.enable {
    programs.zsh.shellAliases =
      shellAliases
      // {
        dsize = "du -hs";
        open = "xdg-open";
        psv = "source .venv/bin/activate";
        l = "eza --icons -a --group-directories-first -1";
        ll = "eza --icons -a --group-directories-first -1 --long -g";
        ns = "nom-shell --run zsh";
        nix-dev = "nom develop --command zsh";
      };
  };
}
