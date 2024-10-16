{
  description = "EloToJa's nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nur.url = "github:nix-community/NUR";

    hyprland = {
      type = "git";
      url = "https://github.com/hyprwm/Hyprland";
      submodules = true;
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    spicetify-nix = {
      url = "github:gerg-l/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wezterm.url = "github:wez/wezterm/main?dir=nix";
    hypr-contrib.url = "github:hyprwm/contrib";
    nix-gaming.url = "github:fufexan/nix-gaming";
    hyprmag.url = "github:SIMULATAN/hyprmag";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = { nixpkgs, self, ...}@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    lib = nixpkgs.lib;
    variables = {
      username = "elotoja";
      git = {
        userName = "EloToJaa";
        userEmail = "elotoja@protonmail.com";
      };
      catppuccin = {
        flavor = "mocha";
        accent = "blue";
      };
      timezone = "Europe/Warsaw";
      locale = "en_GB.UTF-8";
      keyboardLayout = "pl,pl";
      stateVersion = "24.05";
      nfs = "truenas.eagle-perch.ts.net";
    };
  in
  {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./hosts/desktop ];
        specialArgs = { host="desktop"; inherit self inputs variables; };
      };
      laptop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./hosts/laptop ];
        specialArgs = { host="laptop"; inherit self inputs variables; };
      };
       vm = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./hosts/vm ];
        specialArgs = { host="vm"; inherit self inputs variables; };
      };
    };
  };
}
