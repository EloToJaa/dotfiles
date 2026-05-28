{lib, ...}: {
  options.modules.ai = {
    enable = lib.mkEnableOption "Enable ai module";
    skills = lib.mkOption {
      type = lib.types.attrsOf (lib.types.either lib.types.path lib.types.str);
      default = {};
      description = ''
        Shared agent skill registry. Add a skill here once and the enabled
        adapters expose it to opencode, pi, and future agents.
      '';
    };
  };
  imports = [
    ./ollama.nix
    ./opencode.nix
    ./pi.nix
    ./skills.nix
    ./workmux.nix
  ];
}
