# Shared hardware selection

Declare CPU and GPU vendors in each machine's `configuration.nix`:

```nix
modules.shared = {
  cpu.vendor = "amd"; # "intel" or "amd"
  graphics = {
    enable = true;
    vendor = "amd"; # "intel", "amd", or "nvidia"
  };
};
```

CPU selection enables the vendor's microcode updates when redistributable firmware is enabled. Graphics selection configures the vendor's driver when `graphics.enable` is enabled. The core module enables graphics by default for workstations; servers can enable it independently.

Both vendor options default to `null`, leaving vendor-specific configuration to other modules. `graphics.earlyBoot` controls loading the selected GPU driver in the initrd, and `graphics.enable32Bit` controls 32-bit graphics libraries.

NVIDIA defaults to open kernel modules for Turing or newer GPUs. For older cards, set `graphics.nvidia.open = false` and choose a compatible native `hardware.nvidia.branch`. Native NixOS options remain available for driver packages and PRIME configurations.

Add vendor-specific packages and settings to `cpu/intel.nix`, `cpu/amd.nix`, or the corresponding file under `graphics/`. Other modules can also condition their software on `config.modules.shared.cpu.vendor` or `config.modules.shared.graphics.vendor` without adding software lists to machine declarations.
