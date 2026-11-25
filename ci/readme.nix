{
  lib,
  self,
  ...
}: let
  START = "<!-- services:start -->";
  END = "<!-- services:end -->";

  hostSites = host: map (site: site // {inherit host;}) (self.nixosConfigurations.${host}.config.modules.homelab.glance.sites or []);

  sites = lib.sortOn (site: [site.group (lib.toLower site.title)]) (
    lib.concatMap hostSites (lib.attrNames self.nixosConfigurations)
  );

  header = ["Service" "Group" "Host"];
  rows = map (site: ["[${site.title}](${site.url})" site.group "`${site.host}`"]) sites;

  widths = lib.genList (
    column: lib.foldl' lib.max 3 (map (row: lib.stringLength (lib.elemAt row column)) ([header] ++ rows))
  ) (lib.length header);

  pad = width: text: text + lib.concatStrings (lib.replicate (width - lib.stringLength text) " ");

  formatRow = row: "| ${lib.concatStringsSep " | " (lib.zipListsWith pad widths row)} |";

  # Columns are padded the way `nix fmt` aligns Markdown tables, so the check stays green after formatting.
  servicesTable = lib.concatStringsSep "\n" (
    [
      START
      ""
      (formatRow header)
      (formatRow (map (width: lib.concatStrings (lib.replicate width "-")) widths))
    ]
    ++ map formatRow rows
    ++ [
      ""
      END
    ]
  );
in {
  perSystem = {pkgs, ...}: let
    services = pkgs.writeText "readme-services.md" (servicesTable + "\n");

    awk = program: file: "${lib.getExe pkgs.gawk} -v start=${lib.escapeShellArg START} -v end=${lib.escapeShellArg END} -v table=${services} ${lib.escapeShellArg program} ${file}";

    extractSection = awk ''
      $0 == start { inside = 1 }
      inside { print }
      $0 == end { inside = 0 }
    '';

    replaceSection = awk ''
      $0 == start { while ((getline line < table) > 0) print line; skip = 1; next }
      $0 == end { skip = 0; next }
      !skip { print }
    '';
  in {
    apps.readme-services = {
      type = "app";
      meta.description = "Regenerate the homelab service list in README.md from modules.homelab.glance.sites";
      program = lib.getExe (pkgs.writeShellScriptBin "readme-services" ''
        set -euo pipefail
        readme="''${1:-README.md}"
        if ! grep -qxF ${lib.escapeShellArg START} "$readme"; then
          echo "$readme has no ${START} marker" >&2
          exit 1
        fi
        tmp=$(mktemp)
        ${replaceSection "$readme"} > "$tmp"
        mv "$tmp" "$readme"
      '');
    };

    checks.readme-services = pkgs.runCommand "readme-services" {} ''
      ${extractSection ../README.md} > current.md
      if ! diff -u current.md ${services}; then
        echo "README.md service list is out of date, run: just readme" >&2
        exit 1
      fi
      touch $out
    '';
  };
}
