{lib, ...}: {
  options.modules.dev.ai = {
    enable = lib.mkEnableOption "Enable ai module";
  };
  imports = [
    ./btca.nix
    ./opencode.nix
    ./skills.nix
    ./workmux.nix
  ];
}
