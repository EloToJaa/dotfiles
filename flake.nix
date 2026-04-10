{
  description = "EloToJa's NixOS configuration";

  outputs = {flake-parts, ...} @ inputs: let
    inherit ((import ./overlays.nix {inherit inputs;})._module.args) overlaysList;
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
      ];

      imports = [
        inputs.clan-core.flakeModules.default
        inputs.devshell.flakeModule
        # ./terranix
        ./lib
        ./settings.nix
        ./machines/flake-module.nix
        ./pkgs
        ./overlays.nix
      ];

      perSystem = {
        system,
        pkgs,
        ...
      }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = overlaysList;
          config.allowUnfree = true;
        };

        devshells.default.packages = with pkgs.unstable; [
          nurl
        ];
      };
    };

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nur.url = "github:nix-community/NUR";
    flake-parts.url = "github:hercules-ci/flake-parts";
    terranix.url = "github:terranix/terranix";
    devshell.url = "github:numtide/devshell";

    clan-core = {
      url = "https://git.clan.lol/clan/clan-core/archive/25.11.tar.gz";
      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-parts.follows = "flake-parts";
        sops-nix.follows = "sops-nix";
      };
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # danksearch = {
    #   url = "github:AvengeMedia/danksearch";
    #   inputs.nixpkgs.follows = "nixpkgs-unstable";
    # };

    hyprland = {
      url = "github:hyprwm/Hyprland/v0.54.2?submodules=true";
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
    vicinae-extensions = {
      url = "github:vicinaehq/extensions";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
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

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    nixos-needsreboot.url = "https://flakehub.com/f/wimpysworld/nixos-needsreboot/*.tar.gz";
  };
}
