{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.jellystat;

  nameToEnvVar = name: let
    parts = builtins.split "([A-Z0-9]+)" name;
    partsToEnvVar = parts:
      lib.foldl' (
        key: x: let
          last = lib.stringLength key - 1;
        in
          if lib.isList x
          then key + lib.optionalString (key != "" && lib.substring last 1 key != "_") "_" + lib.head x
          else if key != "" && lib.elem (lib.substring 0 1 x) lib.lowerChars
          then # to handle e.g. [ "disable" [ "2FAR" ] "emember" ]
            lib.substring 0 last key
            + lib.optionalString (lib.substring (last - 1) 1 key != "_") "_"
            + lib.substring last 1 key
            + lib.toUpper x
          else key + lib.toUpper x
      ) ""
      parts;
  in
    if builtins.match "[A-Z0-9_]+" name != null
    then name
    else partsToEnvVar parts;

  configEnv =
    lib.concatMapAttrs (
      name: value:
        lib.optionalAttrs (value != null) {
          ${nameToEnvVar name} =
            if lib.isBool value
            then lib.boolToString value
            else toString value;
        }
    )
    cfg.config;

  configFile = pkgs.writeText "vaultwarden.env" (
    lib.concatStrings (lib.mapAttrsToList (name: value: "${name}=${value}\n") configEnv)
  );
in {
  meta.maintainers = [lib.maintainers.kashw2];

  options.services.jellystat = {
    enable = lib.mkEnableOption "Jellystat, a free and open source Statistics App for Jellyfin";

    package = lib.mkPackageOption pkgs "jellystat" {};

    user = lib.mkOption {
      type = lib.types.str;
      default = "jellystat";
      description = "The user to run the service as.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "jellystat";
      description = "The group to run the service as.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open port in the firewall for the Jellystat web interface.";
    };

    config = lib.mkOption {
      type = with lib.types;
        attrsOf (
          nullOr (oneOf [
            bool
            int
            str
          ])
        );
    };

    environmentFile = lib.mkOption {
      type = lib.types.path;
      description = "The path to the environment file to be used during authentication.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.jellystat = {
      description = "Jellystat, a free and open source Statistics App for Jellyfin";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        DynamicUser = false;
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = "${cfg.package}/backend";
        ExecStart = "${pkgs.nodejs}/bin/node ./server.js";
        EnvironmentFile = [configFile cfg.environmentFile];
      };
    };

    users.users.${cfg.user} = {
      inherit (cfg) group;
      description = cfg.user;
      isSystemUser = true;
    };
    users.groups.${cfg.group} = {};

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.port];
    };
  };
}
