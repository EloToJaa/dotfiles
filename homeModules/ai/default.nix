{lib, ...}: {
  options.modules.ai = {
    enable = lib.mkEnableOption "Enable ai module";
  };
  imports = [
    ./ollama.nix
    ./opencode.nix
    ./pi.nix
    ./skills.nix
    ./workmux.nix
  ];
}
