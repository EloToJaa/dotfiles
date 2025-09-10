{
  description = "EloToJa's NixOS configuration";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nur.url = "github:nix-community/NUR";

    # systemd-nixpkgs.url = "github:nixos/nixpkgs/ed30f8aba41605e3ab46421e3dcb4510ec560ff8"; # 257.3
    # systemd-nixpkgs.url = "github:nixos/nixpkgs/5395fb3ab3f97b9b7abca147249fa2e8ed27b192"; # 257.5
    systemd-nixpkgs.url = "github:nixos/nixpkgs/372d9eeeafa5b15913201e2b92e8e539ac7c64d1"; # 257.6

    hyprland = {
      url = "github:hyprwm/Hyprland/main?submodules=true";
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
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    spicetify-nix = {
      url = "github:gerg-l/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    walker = {
      url = "github:abenz1267/walker/1.0.0";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    yazi = {
      url = "github:sxyazi/yazi/main";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    wezterm = {
      url = "github:wezterm/wezterm/main?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    hypr-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.home-manager.follows = "home-manager";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    pwndbg = {
      url = "github:pwndbg/pwndbg";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
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
