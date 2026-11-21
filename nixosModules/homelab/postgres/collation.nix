{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.postgresql;
  psql = "${lib.getExe' cfg.finalPackage "psql"} --no-psqlrc --quiet --tuples-only --no-align";

  refresh_collation = pkgs.writeShellScript "postgresql-refresh-collation" ''
    set -u
    failed=0

    mismatched=$(${psql} --dbname=postgres --command "
      SELECT datname FROM pg_database
      WHERE datallowconn
        AND datcollversion IS NOT NULL
        AND datcollversion IS DISTINCT FROM pg_database_collation_actual_version(oid)")

    if [ -z "$mismatched" ]; then
      echo "No database has a collation version mismatch"
      exit 0
    fi

    for db in $mismatched; do
      echo "Database $db: collation version mismatch, reindexing"
      if ${psql} --dbname="$db" --command "REINDEX DATABASE CONCURRENTLY \"$db\"" \
        && ${psql} --dbname="$db" --command "REINDEX SYSTEM \"$db\"" \
        && ${psql} --dbname="$db" --command "ALTER DATABASE \"$db\" REFRESH COLLATION VERSION"; then
        echo "Database $db: collation version refreshed"
      else
        echo "Database $db: refresh failed, will retry on next start" >&2
        failed=1
      fi
    done

    exit $failed
  '';
in {
  config = lib.mkIf cfg.enable {
    systemd.services.postgresql-refresh-collation = {
      description = "Reindex PostgreSQL databases with a stale collation version";
      after = ["postgresql.target"];
      wants = ["postgresql.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        ExecStart = refresh_collation;
      };
    };
  };
}
