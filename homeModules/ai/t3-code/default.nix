{
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.ai.t3-code;
  t3codePackages = pkgs.unstable.llm-agents;
  settings_path = "${config.home.homeDirectory}/.t3/userdata/settings.json";
  hub_url = "https://hub.server.elotoja.com";
  hub_source = "cliproxy-hub.server.elotoja.com";
  hub_key_path = osConfig.clan.core.vars.generators.t3code-hub.files.management-key.path;
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
      # merged into the live files on activation so T3 can still edit them
      userSettings = lib.recursiveUpdate (lib.importJSON ./settings.json) {
        # the management key is a secret, written by t3codeHubManagementKey below
        usageLimitSources.${hub_source} = {
          kind = "cliproxy";
          url = hub_url;
          enabled = true;
        };
      };
      clientSettings = lib.importJSON ./client-settings.json;
      keybindings = lib.importJSON ./keybindings.json;
    };

    # Inject the CLIProxyAPI management key from clan vars so it stays out of the store
    home.activation.t3codeHubManagementKey = lib.hm.dag.entryAfter ["t3codeSettingsActivation"] ''
      key_file=${lib.escapeShellArg hub_key_path}
      settings=${lib.escapeShellArg settings_path}
      if [ ! -r "$key_file" ]; then
        echo "T3 Code: $key_file is not readable, skipping hub management key" >&2
      elif [[ -v DRY_RUN ]]; then
        echo "Would set the T3 Code hub management key in $settings"
      else
        tmp=$(${lib.getExe' pkgs.coreutils "mktemp"} "$settings.XXXXXXXX")
        ${lib.getExe' pkgs.coreutils "chmod"} 600 "$tmp"
        if ${lib.getExe pkgs.jq} --rawfile key "$key_file" --arg id ${lib.escapeShellArg hub_source} \
          '.usageLimitSources[$id].managementKey = ($key | sub("\\s+$"; ""))' "$settings" > "$tmp"; then
          ${lib.getExe' pkgs.coreutils "mv"} -f "$tmp" "$settings"
        else
          ${lib.getExe' pkgs.coreutils "rm"} -f "$tmp"
          echo "T3 Code: failed to set the hub management key in $settings" >&2
        fi
      fi
    '';

    # Electron can't register itself in the read-only Home Manager mimeapps.list,
    # so browsers never route T3 Connect's t3code:// OAuth callback to the app.
    xdg.mimeApps.defaultApplications = lib.mkIf cfg.desktop.enable {
      "x-scheme-handler/t3code" = "t3code.desktop";
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
