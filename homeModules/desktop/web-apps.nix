{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types;
  cfg = config.modules.desktop;

  webAppType = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "Display name shown by application launchers.";
      };
      url = mkOption {
        type = types.str;
        description = ''
          HTTPS URL opened by the web app. Do not include credentials, access
          tokens, or other secrets in this value because it is stored in the
          world-readable Nix store.
        '';
      };
      icon = mkOption {
        type = types.either types.str types.path;
        default = "web-browser";
        description = "Icon name or path used by the desktop entry.";
      };
      categories = mkOption {
        type = types.listOf types.str;
        default = ["Network"];
        description = "Freedesktop categories assigned to the desktop entry.";
      };
      comment = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Optional description shown by application launchers.";
      };
      browserArguments = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional arguments passed to Chromium before the app URL.";
      };
      isolatedProfile = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Use a profile dedicated to this web app instead of Chromium's shared
          profile. The profile is stored below XDG_DATA_HOME.
        '';
      };
    };
  };

  makeLauncher = id: app:
    pkgs.writeShellScript "launch-web-app-${id}" ''
      profile_args=()
      browser_args=(${lib.escapeShellArgs app.browserArguments})
      ${lib.optionalString app.isolatedProfile ''
        data_home="''${XDG_DATA_HOME:-$HOME/.local/share}"
        profile_args+=("--user-data-dir=$data_home/web-apps/${id}")
      ''}
      exec ${lib.getExe pkgs.unstable.chromium} \
        "''${profile_args[@]}" \
        "''${browser_args[@]}" \
        ${lib.escapeShellArg "--app=${app.url}"}
    '';

  makeDesktopEntry = id: app: {
    name = app.name;
    exec = lib.getExe (makeLauncher id app);
    icon = toString app.icon;
    inherit (app) categories;
    comment = lib.optionalString (app.comment != null) app.comment;
    terminal = false;
    type = "Application";
  };
in {
  options.modules.desktop.webApps = mkOption {
    type = types.attrsOf webAppType;
    default = {};
    description = ''
      Web apps exposed as native desktop entries and launched in Chromium app
      windows. Attribute names become deterministic desktop entry IDs. URLs
      must not contain credentials, tokens, or other secrets.
    '';
    example = {
      notifications = {
        name = "Notifications";
        url = "https://notifications.example.com";
        icon = "preferences-system-notifications";
        categories = ["Network" "Utility"];
      };
    };
  };

  config = lib.mkIf (cfg.enable && cfg.webApps != {}) {
    assertions = lib.concatLists (lib.mapAttrsToList (id: app: [
        {
          assertion = builtins.match "^[a-z0-9][a-z0-9-]*$" id != null;
          message = "modules.desktop.webApps attribute names must contain only lowercase letters, numbers, and hyphens";
        }
        {
          assertion = builtins.match "^https://.*" app.url != null;
          message = "modules.desktop.webApps.${id}.url must use HTTPS";
        }
        {
          assertion = builtins.match "^[A-Za-z][A-Za-z0-9+.-]*://[^/]*@.*" app.url == null;
          message = "modules.desktop.webApps.${id}.url must not contain credentials";
        }
      ])
      cfg.webApps);
    xdg.desktopEntries = lib.mapAttrs makeDesktopEntry cfg.webApps;
  };
}
