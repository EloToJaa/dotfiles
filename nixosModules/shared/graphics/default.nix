{
  lib,
  config,
  ...
}: let
  cfg = config.modules.shared.graphics;
in {
  imports = [
    ./intel.nix
    ./amd.nix
    ./nvidia.nix
  ];

  options.modules.shared.graphics = {
    enable = lib.mkEnableOption "graphics support for workstations or GPU workloads";
    enable32Bit = lib.mkEnableOption "32-bit graphics support";
    vendor = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum ["intel" "amd" "nvidia"]);
      default = null;
      description = "GPU vendor to configure. Null enables graphics libraries without selecting a driver.";
    };
    earlyBoot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Load the selected GPU driver in the initrd.";
    };
    nvidia.open = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use NVIDIA's open kernel modules for Turing or newer GPUs. Set false for older GPUs and select a compatible hardware.nvidia.branch.";
    };
  };
  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      inherit (cfg) enable32Bit;
    };
  };
}
