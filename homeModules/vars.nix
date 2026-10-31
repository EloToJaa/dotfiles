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
    leetcode = lib.mkIf hm.modules.dev.leetcode.enable {
      share = true;
      prompts = {
        csrftoken = {
          description = "LeetCode csrftoken cookie";
          type = "hidden";
          persist = true;
        };
        session = {
          description = "LeetCode LEETCODE_SESSION cookie";
          type = "hidden";
          persist = true;
        };
      };
      files = {
        csrftoken.deploy = false;
        session.deploy = false;
      };
    };
    leetcode-config = lib.mkIf hm.modules.dev.leetcode.enable {
      share = true;
      dependencies = ["leetcode"];
      files."leetcode.toml" = {inherit owner group;};
      script = ''
        cat > "$out/leetcode.toml" <<EOF
        [code]
        editor = "nvim"
        #lang = "cpp"
        lang = "python3"
        #comment_leading = "//"
        comment_leading = "#"
        comment_problem_desc = true
        test = true
        #inject_before = ["#include<bits/stdc++.h>\\n", "using namespace std;\\n"]
        #inject_after = [""]

        [cookies]
        csrf = "$(cat "$in/leetcode/csrftoken")"
        session = "$(cat "$in/leetcode/session")"
        site = "leetcode.com"

        [storage]
        cache = "problems.db"
        code = "${hm.home.homeDirectory}/code/leetcode"
        root = "~/.leetcode"
        scripts = "${hm.home.homeDirectory}/code/leetcode/scripts"
        EOF
      '';
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
