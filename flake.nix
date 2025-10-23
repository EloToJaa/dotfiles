{
  description = "EloToJa's NixOS configuration";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nur.url = "github:nix-community/NUR";
    flake-parts.url = "github:hercules-ci/flake-parts";

    hyprland = {
      url = "github:hyprwm/Hyprland/v0.51.1?submodules=true";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
    vicinae = {
      url = "github:vicinaehq/vicinae";
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

    nixos-needsreboot.url = "https://flakehub.com/f/wimpysworld/nixos-needsreboot/*.tar.gz";
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./nixosModules
        ./homeModules
        ./pkgs
        ./hosts
      ];
      flake.modules.settings = import ./settings;

      systems = [
        "x86_64-linux"
      ];
      perSystem = {system, ...}: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = import ./overlays {inherit inputs;};
          config = {allowUnfree = true;};
        };
      };
    };

  # packages = {
  #   ${system} = let
  #     # Import nixpkgs for the target system, applying overlays directly
  #     pkgsWithOverlays = import nixpkgs {
  #       inherit system;
  #       config = {allowUnfree = true;}; # Ensure consistent config
  #       # Pass the list of overlay functions directly
  #       overlays = builtins.attrValues self.overlays;
  #     };
  #     # Import the function from pkgs/default.nix
  #     pkgsFunction = import ./pkgs;
  #     # Call the function with the fully overlaid package set
  #     customPkgs = pkgsFunction pkgsWithOverlays;
  #   in
  #     # Return the set of custom packages
  #     customPkgs;
  # };
  # deploy.nodes = let
  #   configs = self.nixosConfigurations;
  #   domain = "eagle-perch.ts.net";
  #   user = "elotoja";
  # in {
  #   server = {
  #     hostname = "server.${domain}";
  #     profiles.system = {
  #       inherit user;
  #       path = deploy-rs.lib.x86_64-linux.activate.nixos configs.server;
  #       interactiveSudo = true;
  #     };
  #   };
  #   laptop = {
  #     hostname = "laptop.${domain}";
  #     profiles.system = {
  #       inherit user;
  #       path = deploy-rs.lib.x86_64-linux.activate.nixos configs.laptop;
  #       interactiveSudo = true;
  #     };
  #   };
  # };
  # checks = builtins.mapAttrs (_: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
}
