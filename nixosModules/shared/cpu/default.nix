{lib, ...}: {
  imports = [
    ./intel.nix
    ./amd.nix
  ];

  options.modules.shared.cpu.vendor = lib.mkOption {
    type = lib.types.nullOr (lib.types.enum ["intel" "amd"]);
    default = null;
    description = "CPU vendor whose microcode updates should be enabled. Null leaves CPU configuration unchanged.";
  };
}
