{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (config.settings) username isServer ntfy;
  owner = username;
  group = username;
  hm = config.home-manager.users.${username};
  ntfyClient = (pkgs.formats.yaml {}).generate "ntfy-client.yml" {
    "default-host" = ntfy;
    "default-user" = username;
    "default-password" = "NTFY_PASSWORD_PLACEHOLDER";
    subscribe = [
      {
        topic = "elotoja";
        command = ''notify-send "Important" "$message"'';
      }
      {
        topic = "uptime";
        command = ''notify-send "$topic" "$message"'';
      }
    ];
  };
in {
  clan.core.vars.generators = {
    dav = {
      share = true;
      files = {
        passwd = {
          inherit owner group;
          secret = true;
          deploy = false;
        };
      };
      runtimeInputs = with pkgs; [
        pwgen
      ];
      script = ''
        pwgen -s 64 1 > $out/passwd
      '';
    };
    accounts = lib.mkIf (!isServer) {
      share = true;
      files = {
        dav-passwd = {
          inherit owner group;
          secret = true;
          deploy = true;
        };
      };
      dependencies = [
        "dav"
      ];
      script = ''
        cp $in/dav/passwd $out/dav-passwd
      '';
    };
    aoc = lib.mkIf hm.modules.dev.aoc.enable {
      share = true;
      prompts.session = {
        description = "Advent of Code session cookie";
        type = "hidden";
        persist = true;
      };
      files.session = {inherit owner group;};
    };
    anthropic = lib.mkIf hm.modules.ai.claude.enable {
      share = true;
      prompts.auth-token = {
        description = "ANTHROPIC_AUTH_TOKEN for Claude Code";
        type = "hidden";
        persist = true;
      };
      files.auth-token = {inherit owner group;};
    };
    ntfy-sh = lib.mkIf hm.modules.desktop.notifications.enable {
      share = true;
      prompts.password = {
        description = "ntfy password for ${username}";
        type = "hidden";
        persist = true;
      };
      files.password.deploy = false;
    };
    ntfy-client = lib.mkIf hm.modules.desktop.notifications.enable {
      share = true;
      dependencies = ["ntfy-sh"];
      files."client.yml" = {inherit owner group;};
      script = ''
        template=$(cat ${ntfyClient})
        password=$(cat "$in/ntfy-sh/password")
        printf '%s\n' "''${template//NTFY_PASSWORD_PLACEHOLDER/"$password"}" > "$out/client.yml"
      '';
    };
  };
}
