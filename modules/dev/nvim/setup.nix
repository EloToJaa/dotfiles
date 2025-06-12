{
  pkgs,
  inputs,
  config,
  ...
}: let
  shellAliases = {
    vim = "nvim";
    vi = "nvim";
    v = "nvim";
  };
  makeBinPath = pkgs.lib.makeBinPath;
  homeDirectory = config.home.homeDirectory;
in {
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    MANPAGER = "nvim +Man!";
    PATH = "${makeBinPath ["${homeDirectory}/go"]}:${makeBinPath ["${homeDirectory}/.cargo"]}:${makeBinPath ["${homeDirectory}/.local"]}:${homeDirectory}/.dotnet:$PATH";
  };

  # nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

  programs = {
    zsh.shellAliases = shellAliases;
    nushell = {
      shellAliases = shellAliases;
      extraEnv = ''
        $env.Path = ($env.Path | prepend ["${makeBinPath ["${homeDirectory}/go"]}" "${makeBinPath ["${homeDirectory}/.cargo"]}" "${makeBinPath ["${homeDirectory}/.local"]}" "${homeDirectory}/.dotnet"]);
      '';
    };
  };
}
