{
  pkgs,
  config,
  osConfig,
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
    home.file.".leetcode/leetcode.toml".source =
      config.lib.file.mkOutOfStoreSymlink osConfig.clan.core.vars.generators.leetcode-config.files."leetcode.toml".path;
  };
}
