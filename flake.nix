{
  description = "EloToJa's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    hyprland = {
      url = "github:hyprwm/Hyprland/main?submodules=true";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yazi.url = "github:sxyazi/yazi";

    sops-nix.url = "github:Mic92/sops-nix";

    wezterm.url = "github:wez/wezterm/4a210168e159fef35db77ad28cda14eea9652790?dir=nix";
    hypr-contrib.url = "github:hyprwm/contrib";
    nix-gaming.url = "github:fufexan/nix-gaming";
    hyprmag.url = "github:SIMULATAN/hyprmag";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    catppuccin.url = "github:catppuccin/nix";
    pwndbg.url = "github:pwndbg/pwndbg";
  };

  outputs = {
    nixpkgs,
    self,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    lib = nixpkgs.lib;
    variables = {
      username = "elotoja";
      email = "elotoja@protonmail.com";
      git = {
        userName = "EloToJaa";
        userEmail = variables.email;
      };
      catppuccin = {
        flavor = "mocha";
        accent = "blue";
      };
      timezone = "Europe/Warsaw";
      locale = "en_GB.UTF-8";
      keyboardLayout = "pl,pl";
      stateVersion = "25.05";
      dns = ["192.168.0.31" "9.9.9.9" "149.112.112.112"];
      nfs = {
        local = "192.168.0.41";
        remote = "truenas.eagle-perch.ts.net";
      };
      ssh.keys = {
        user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMtWaehMf7X23uUZDY5J4fG4/exqj5jWQVaLLXloaO/g elotoja@protonmail.com";
      };
      atuin = {
        local = "https://atuin.local.elotoja.com";
        remote = "https://atuin.server.elotoja.com";
      };
      loki = {
        local = "https://loki.local.elotoja.com";
        remote = "https://loki.server.elotoja.com";
      };
      homelab = {
        baseDomain = "server.elotoja.com";
        dataDir = "/opt/";
        varDataDir = "/var/lib/";
        logDir = "/var/log/";
        defaultUMask = "027";
        groups = {
          main = "homelab";
          media = "media";
          photos = "photos";
          docs = "documents";
          database = "database";
        };
      };
    };
  in {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [./hosts/desktop];
        specialArgs = {
          host = "desktop";
          inherit self inputs variables;
        };
      };
      laptop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [./hosts/laptop];
        specialArgs = {
          host = "laptop";
          inherit self inputs variables;
        };
      };
      server = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [./hosts/server];
        specialArgs = {
          host = "server";
          inherit self inputs variables;
        };
      };
      tester = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [./hosts/tester];
        specialArgs = {
          host = "tester";
          inherit self inputs variables;
        };
      };
      vm = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [./hosts/vm];
        specialArgs = {
          host = "vm";
          inherit self inputs variables;
        };
      };
    };
  };
}
