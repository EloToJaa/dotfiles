{lib, ...}: {
  options.modules.dev.ai = {
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
