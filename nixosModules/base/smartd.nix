{
  lib,
  config,
  ...
}: {
  options.modules.base.smartd.enable = lib.mkEnableOption "S.M.A.R.T. disk monitoring";

  config = lib.mkIf config.modules.base.enable {
    services.smartd.enable = config.modules.base.smartd.enable;
  };
}
