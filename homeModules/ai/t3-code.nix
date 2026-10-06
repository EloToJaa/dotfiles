{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.t3-code;
  t3codePackages = pkgs.unstable.llm-agents;
  service_args =
    [
      "serve"
      "--host"
      "127.0.0.1"
      "--port"
      (toString cfg.service.port)
      "--base-dir"
      "${config.home.homeDirectory}/.t3"
    ]
    ++ lib.optionals cfg.service.tailscaleServe.enable [
      "--tailscale-serve"
      "--tailscale-serve-port"
      (toString cfg.service.tailscaleServe.port)
    ];
in {
  options.modules.ai.t3-code = {
    enable = lib.mkEnableOption "Enable T3 Code module";
    desktop.enable = lib.mkEnableOption "Enable T3 Code desktop client";
    service = {
      enable = lib.mkEnableOption "Run the T3 Code backend as a persistent user service";
      port = lib.mkOption {
        type = lib.types.port;
        default = 3773;
        description = "Local HTTP port for the T3 Code backend.";
      };
      tailscaleServe = {
        enable = lib.mkEnableOption "Publish the T3 Code backend over Tailscale HTTPS";
        port = lib.mkOption {
          type = lib.types.port;
          default = 443;
          description = "HTTPS port for Tailscale Serve.";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      [pkgs.unstable.nodejs_26] # remote environments
      ++ lib.optionals cfg.desktop.enable [t3codePackages.t3code-desktop];
    programs.t3code = {
      enable = true;
      package = t3codePackages.t3code;
    };

    systemd.user.services.t3code = lib.mkIf cfg.service.enable {
      Unit.Description = "T3 Code backend";
      Service = {
        WorkingDirectory = config.home.homeDirectory;
        Environment = [
          "T3CODE_NO_BROWSER=1"
          "PATH=${config.home.profileDirectory}/bin:/run/current-system/sw/bin"
        ];
        # Check Serve permissions before launch: T3 only logs proxy setup failures.
        ExecStartPre = lib.optionals cfg.service.tailscaleServe.enable [
          "${lib.getExe pkgs.unstable.tailscale} wait --timeout=60s"
          "${lib.getExe pkgs.unstable.tailscale} serve --bg --https=${toString cfg.service.tailscaleServe.port} http://127.0.0.1:${toString cfg.service.port}"
        ];
        ExecStart = "${lib.getExe config.programs.t3code.package} ${lib.escapeShellArgs service_args}";
        Restart = "always";
        RestartSec = 5;
        TimeoutStartSec = 120;
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
