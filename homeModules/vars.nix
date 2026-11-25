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
    anthropic = lib.mkIf (hm.modules.ai.claude.enable || hm.modules.ai.grok.enable) {
      share = true;
      prompts.auth-token = {
        description = "ANTHROPIC_AUTH_TOKEN for Claude Code";
        type = "hidden";
        persist = true;
      };
      files.auth-token = {inherit owner group;};
    };
    # bearer token shared by the ai-memory server and every client; derived
    # generators deploy it as the server env file and the user's token file
    ai-memory = lib.mkIf (hm.modules.ai.memory.enable || config.modules.homelab.ai-memory.enable) {
      share = true;
      files.auth-token.deploy = false;
      runtimeInputs = [pkgs.openssl];
      script = ''
        openssl rand -hex 32 > "$out/auth-token"
      '';
    };
    ai-memory-client = lib.mkIf hm.modules.ai.memory.enable {
      share = true;
      dependencies = ["ai-memory"];
      files.auth-token = {inherit owner group;};
      script = ''
        cp "$in/ai-memory/auth-token" "$out/auth-token"
      '';
    };
    grafana-mcp = lib.mkIf hm.modules.ai.grafana.enable {
      share = true;
      prompts.token = {
        description = "Grafana service account token (Viewer role) for the Grafana MCP server";
        type = "hidden";
        persist = true;
      };
      files.token = {inherit owner group;};
    };
    truenas-mcp = lib.mkIf hm.modules.ai.truenas.enable {
      share = true;
      prompts.api-key = {
        description = "TrueNAS API key (Read-Only Administrator) for the TrueNAS MCP server";
        type = "hidden";
        persist = true;
      };
      files.api-key = {inherit owner group;};
    };
    unifi-mcp = lib.mkIf hm.modules.ai.unifi.enable {
      share = true;
      prompts = {
        username = {
          description = "UniFi OS local admin username for the UniFi Network MCP server";
          persist = true;
        };
        password = {
          description = "UniFi OS local admin password for the UniFi Network MCP server";
          type = "hidden";
          persist = true;
        };
      };
      files = {
        username.deploy = false;
        password.deploy = false;
      };
    };
    unifi-mcp-settings = lib.mkIf hm.modules.ai.unifi.enable {
      share = true;
      dependencies = ["unifi-mcp"];
      files."settings.env" = {inherit owner group;};
      script = ''
        {
          printf 'UNIFI_NETWORK_USERNAME=%s\n' "$(cat "$in/unifi-mcp/username")"
          printf 'UNIFI_NETWORK_PASSWORD=%s\n' "$(cat "$in/unifi-mcp/password")"
        } > "$out/settings.env"
      '';
    };
    t3code-hub = lib.mkIf hm.modules.ai.t3-code.enable {
      share = true;
      prompts.management-key = {
        description = "CLIProxyAPI management key (clan vars get server cliproxyapi/management-key)";
        type = "hidden";
        persist = true;
      };
      files.management-key = {inherit owner group;};
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
