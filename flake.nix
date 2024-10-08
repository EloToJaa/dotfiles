{
  description = "EloToJa's nixos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
  
    hypr-contrib.url = "github:hyprwm/contrib";
    hyprpicker.url = "github:hyprwm/hyprpicker";
  
    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
  
    nix-gaming.url = "github:fufexan/nix-gaming";
  
    hyprland = {
      type = "git";
      url = "https://github.com/hyprwm/Hyprland";
      submodules = true;
    };
  
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    spicetify-nix = {
      url = "github:gerg-l/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprmag.url = "github:SIMULATAN/hyprmag";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";
    
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = { nixpkgs, self, ...} @ inputs:
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
        accent = "lavender";
      };
      timezone = "Europe/Warsaw";
      locale = "en_GB.UTF-8";
      keyboardLayout = "pl,pl";
    };
  in
  {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./hosts/desktop ];
        specialArgs = { host="desktop"; inherit self inputs variables ; };
      };
      laptop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./hosts/laptop ];
        specialArgs = { host="laptop"; inherit self inputs variables ; };
      };
       vm = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./hosts/vm ];
        specialArgs = { host="vm"; inherit self inputs variables ; };
      };
    };
  };
}
