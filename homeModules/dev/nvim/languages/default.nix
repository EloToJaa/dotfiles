{lib, ...}: {
  options.modules.dev.nvim.languages = {
    enable = lib.mkEnableOption "Enable languages";
  };
  imports = [
    ./bash.nix
    ./c.nix
    ./go.nix
    ./javascript.nix
    ./json.nix
    ./lua.nix
    ./markdown.nix
    ./nix.nix
    ./python.nix
    ./rust.nix
    ./toml.nix
    ./xml.nix
    ./yaml.nix
    ./zig.nix
  ];
}
