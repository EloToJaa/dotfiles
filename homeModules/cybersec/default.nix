{lib, ...}: {
  options.modules.cybersec = {
    enable = lib.mkEnableOption "Enable cybersec module";
  };
  imports = [
    ./scripts
    ./packages.nix
  ];
}
