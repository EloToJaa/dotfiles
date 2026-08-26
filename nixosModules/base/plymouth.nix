{
  lib,
  config,
  ...
}: let
  cfg = config.modules.base.plymouth;
in {
  options.modules.base.plymouth = {
    enable = lib.mkEnableOption "themed Plymouth boot splash and graphical disk unlock prompt";

    flavor = lib.mkOption {
      type = lib.types.enum [
        "latte"
        "frappe"
        "macchiato"
        "mocha"
      ];
      default = config.settings.catppuccin.flavor;
      defaultText = lib.literalExpression "config.settings.catppuccin.flavor";
      description = "Catppuccin flavor used by the Plymouth theme.";
    };

    quiet = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Hide routine kernel messages behind the boot splash.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      initrd.systemd.enable = true;
      kernelParams = lib.optional cfg.quiet "quiet";
      plymouth.enable = true;
    };

    catppuccin.plymouth = {
      enable = true;
      inherit (cfg) flavor;
    };
  };
}
