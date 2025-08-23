{
  description = "EloToJa's NixOS configuration";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nur.url = "github:nix-community/NUR";

    hyprland = {
      url = "github:hyprwm/Hyprland/43966cc787c4a8844ac1e7affaadeedde8f4cc60?submodules=true";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    spicetify-nix = {
      url = "github:gerg-l/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    sops-nix.url = "github:Mic92/sops-nix";
    deploy-rs.url = "github:serokell/deploy-rs";
    yazi.url = "github:sxyazi/yazi/main";
    wezterm.url = "github:wezterm/wezterm/main?dir=nix";
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
    deploy-rs,
    ...
  } @ inputs: let
    inherit (self) outputs;
    system = "x86_64-linux";
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
      terminal = "ghostty"; # wezterm/ghostty/kitty
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
        mainDomain = "elotoja.com";
        baseDomain = "server.${variables.homelab.mainDomain}";
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
          backups = "backups";
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
          inherit self inputs variables outputs;
        };
      };
      laptop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [./hosts/laptop];
        specialArgs = {
          host = "laptop";
          inherit self inputs variables outputs;
        };
      };
      server = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [./hosts/server];
        specialArgs = {
          host = "server";
          inherit self inputs variables outputs;
        };
      };
      tester = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [./hosts/tester];
        specialArgs = {
          host = "tester";
          inherit self inputs variables outputs;
        };
      };
      vm = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [./hosts/vm];
        specialArgs = {
          host = "vm";
          inherit self inputs variables outputs;
        };
      };
    };
    overlays = import ./overlays {inherit inputs;};
    packages = {
      ${system} = let
        # Import nixpkgs for the target system, applying overlays directly
        pkgsWithOverlays = import nixpkgs {
          inherit system;
          config = {allowUnfree = true;}; # Ensure consistent config
          # Pass the list of overlay functions directly
          overlays = builtins.attrValues self.overlays;
        };
        # Import the function from pkgs/default.nix
        pkgsFunction = import ./pkgs;
        # Call the function with the fully overlaid package set
        customPkgs = pkgsFunction pkgsWithOverlays;
      in
        # Return the set of custom packages
        customPkgs;
    };
    deploy.nodes = let
      configs = self.nixosConfigurations;
      domain = "eagle-perch.ts.net";
      user = "elotoja";
    in {
      server = {
        hostname = "server.${domain}";
        profiles.system = {
          user = user;
          path = deploy-rs.lib.x86_64-linux.activate.nixos configs.server;
          interactiveSudo = true;
        };
      };
      laptop = {
        hostname = "laptop.${domain}";
        profiles.system = {
          user = user;
          path = deploy-rs.lib.x86_64-linux.activate.nixos configs.laptop;
          interactiveSudo = true;
        };
      };
    };
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
