{lib, ...}: {
  options.modules.dev.ai = {
    enable = lib.mkEnableOption "Enable ai module";
  };
  imports = [
    ./opencode.nix
    ./skills.nix
    ./workmux.nix
  ];
}
