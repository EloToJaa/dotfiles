{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.modules.core.dms-shell;
  dmsPlugins = pkgs.fetchgit {
    url = "https://github.com/AvengeMedia/dms-plugins";
    rev = "bb90a1db7d540e64ae049c5906afba9b24baa865";
    hash = "sha256-NYmw2wCZYAKNU1xcodKMDXs5wwtAguOUNazRxcLjsUE=";
  };
  dmsPlugin = name:
    pkgs.runCommand "dms-plugin-${name}" {} ''
      mkdir -p $out
      cp -r ${dmsPlugins}/${name}/. $out/
    '';
in {
  options.modules.core.dms-shell.enable = lib.mkEnableOption "DankMaterialShell";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.unstable.dgop];
    programs.dms-shell = {
      enable = true;
      package = pkgs.unstable.dms-shell;
      quickshell.package = pkgs.unstable.quickshell;
      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableDynamicTheming = true;
      enableVPN = true;
      systemd.enable = true;
      plugins = {
        aiOverviewControl.src = pkgs.fetchgit {
          url = "https://github.com/bernardopg/AiOverviewControl";
          rev = "047b1e57bd721a640ddfd764bbbd755e502eca2f";
          hash = "sha256-3kNMQV1SolPhYpeekd6TqJ5VPIX1jcm0mqUkXFVaV7E=";
        };
        dankKDEConnect.src = dmsPlugin "DankKDEConnect";
        dankLauncherKeys.src = dmsPlugin "DankLauncherKeys";
      };
    };
  };
}
