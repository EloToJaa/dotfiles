{
  pkgs,
  inputs,
  ...
}: {
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_6_16;
  };
  systemd.package = inputs.systemd-nixpkgs.legacyPackages.${pkgs.system}.systemd;
}
