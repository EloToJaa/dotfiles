{
  lib,
  config,
  ...
}: let
  cfg = config.settings;
in {
  options.settings = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "elotoja";
    };
    email = lib.mkOption {
      type = lib.types.str;
      default = "elotoja@protonmail.com";
    };
    homeDirectory = lib.mkOption {
      type = lib.types.path;
      default = "/home/${cfg.username}";
    };
    dotfilesDirectory = lib.mkOption {
      type = lib.types.path;
      default = "${cfg.homeDirectory}/Projects/dotfiles";
    };
    uid = lib.mkOption {
      type = lib.types.int;
      default = 1000;
    };
    git.userName = lib.mkOption {
      type = lib.types.str;
      default = "EloToJaa";
    };
    git.userEmail = lib.mkOption {
      type = lib.types.str;
      default = cfg.email;
    };
    catppuccin.flavor = lib.mkOption {
      type = lib.types.str;
      default = "mocha";
    };
    catppuccin.accent = lib.mkOption {
      type = lib.types.str;
      default = "blue";
    };
    terminal = lib.mkOption {
      type = lib.types.str;
      default = "ghostty"; # wezterm/ghostty/kitty
    };
    discord = lib.mkOption {
      type = lib.types.str;
      default = "vesktop"; # discord/vesktop
    };
    timezone = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Warsaw";
    };
    locale = lib.mkOption {
      type = lib.types.str;
      default = "en_GB.UTF-8";
    };
    keyboardLayout = lib.mkOption {
      type = lib.types.str;
      default = "pl,pl";
    };
    stateVersion = lib.mkOption {
      type = lib.types.str;
      default = "25.11";
    };
    dns = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = ["192.168.0.32" "9.9.9.9" "149.112.112.112"];
    };
    nfs.local = lib.mkOption {
      type = lib.types.str;
      default = "192.168.0.41";
    };
    nfs.remote = lib.mkOption {
      type = lib.types.str;
      default = "truenas.eagle-perch.ts.net";
    };
    ssh.keys.user = lib.mkOption {
      type = lib.types.str;
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMtWaehMf7X23uUZDY5J4fG4/exqj5jWQVaLLXloaO/g elotoja@protonmail.com";
    };
    atuin = lib.mkOption {
      type = lib.types.str;
      default = "https://atuin.server.elotoja.com";
    };
    isLaptop = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    isServer = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };
}
