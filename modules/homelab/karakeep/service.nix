{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.karakeep;
  env =
    {
      HOSTNAME = cfg.hostName;
      PORT = toString cfg.webPort;
      DISABLE_NEW_RELEASE_CHECK = "true";
      BROWSER_WEB_URL = "http://${cfg.hostname}:${toString cfg.browserPort}";
      DATA_DIR = cfg.dataDir;
      HOARDER_VERSION = "release";
    }
    // cfg.settings;
in {
  # https://aur.archlinux.org/packages/karakeep
  options.services.karakeep = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Run karakeep
      '';
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/karakeep";
      description = ''
        The directory where karakeep will create files.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "karakeep";
      description = ''
        User account under which karakeep runs.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "karakeep";
      description = ''
        Group under which karakeep runs.
      '';
    };

    hostname = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = ''
        karakeep web UI hostname.
      '';
    };

    webPort = mkOption {
      type = types.port;
      default = 3000;
      description = ''
        karakeep web UI port.
      '';
    };

    browserPort = mkOption {
      type = types.port;
      default = 9222;
      description = ''
        karakeep chromium port.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Open services.karakeep.port to the outside network.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = with lib.types;
          attrsOf (let
            typeList = [bool float int str path package];
          in
            oneOf (typeList ++ [(listOf (oneOf typeList)) (attrsOf (oneOf typeList))]));
      };
      default = {};
      description = ''
        Extra karakeep environment variables.
      '';
    };

    environmentFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/var/lib/vaultwarden.env";
      description = "Additional environment file";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.karakeep
      pkgs.chromium
    ];

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.webPort];
    };

    systemd.targets.karakeep = {
      description = "Karakeep services";
      after = ["network-online.target"];
      wants = [
        "karakeep-web.service"
        "karakeep-workers.service"
        "karakeep-browser.service"
      ];
      wantedBy = ["multi-user.target"];
    };

    systemd.services.karakeep-browser = {
      description = "Karakeep Browser";
      wants = ["network-online.target"];
      after = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        ExecStart = "${pkgs.chromium}/bin/chromium --headless --no-sandbox --disable-gpu --disable-dev-shm-usage --remote-debugging-address=${cfg.hostname} --remote-debugging-port=${toString cfg.browserPort} --hide-scrollbars";
        TimeoutStopSec = "5";
        SyslogIdentifier = "karakeep-browser";
        ProtectSystem = "yes";
        PrivateTmp = "yes";
        NoNewPrivileges = "yes";
      };
    };

    systemd.services.karakeep-web = {
      description = "Karakeep WebUI";
      wants = ["network-online.target" "karakeep-workers.service"];
      after = ["network-online.target" "karakeep-workers.service"];
      wantedBy = ["multi-user.target"];
      environment = env;

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        WorkingDirectory = cfg.dataDir;
        ExecStartPre = "${pkgs.karakeep}/lib/karakeep/migrate";
        ExecStart = "${pkgs.karakeep}/lib/karakeep/start-web";
        TimeoutStopSec = "5";
        SyslogIdentifier = "karakeep-web";
        ProtectSystem = "yes";
        PrivateTmp = "yes";
        NoNewPrivileges = "yes";
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
      };
    };

    systemd.services.karakeep-workers = {
      description = "Karakeep Workers";
      wants = ["network-online.target" "karakeep-browser.service"];
      after = ["network-online.target" "karakeep-browser.service"];
      wantedBy = ["multi-user.target"];
      environment = env;

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "on-failure";
        WorkingDirectory = "${cfg.dataDir}/karakeep/apps/workers";
        ExecStart = "${pkgs.karakeep}/lib/karakeep/start-workers";
        TimeoutStopSec = "5";
        SyslogIdentifier = "karakeep-workers";
        ProtectSystem = "yes";
        PrivateTmp = "yes";
        NoNewPrivileges = "yes";
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
      };
    };

    users.users = mkIf (cfg.user == "karakeep") {
      karakeep = {
        isSystemUser = true;
        group = cfg.group;
        description = "karakeep user";
      };
    };

    users.groups =
      mkIf (cfg.group == "karakeep") {karakeep = {gid = null;};};

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 750 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/cache 750 ${cfg.user} ${cfg.group} - -"
    ];
  };
}
