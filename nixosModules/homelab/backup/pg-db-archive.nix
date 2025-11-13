{
  config,
  pkgs,
  dbName,
  fileEncKey,
  fileRclone,
}: let
  script = pkgs.writeShellScriptBin "pg-db-archive" ''
    #!/usr/bin/env bash

    ## Fail on any error:
    set -e

    ## Define the backup directory path:
    _dirBackup="${config.services.postgresqlBackup.location}"

    ## Define the path to the file to be encrypted:
    _fileBackup="''${_dirBackup}/${dbName}.sql.gz"

    ## Define the path to the encrypted file to be archived:
    _fileArchive="''${_dirBackup}/${dbName}_$(date --utc +%Y%m%dT%H%M%SZ).sql.gz.enc"

    ## Encrypt the file:
    echo "Encrypting database dump..."
    ${pkgs.gnupg}/bin/gpg --symmetric --cipher-algo AES256 --batch --yes --passphrase-file ${fileEncKey} --output "''${_fileArchive}" "''${_fileBackup}"
    echo "Database file is encrypted successfully."

    ## Archive the file:
    echo "Archiving encrypted database dump..."
    ${pkgs.rclone}/bin/rclone --config "${fileRclone}" copy "''${_fileArchive}" "archive-target-database:/${dbName}/"
    echo "Encrypted database file is archived successfully."

    ## Remove the local archive file:
    echo "Removing local encrypted database dump..."
    rm -f "''${_fileArchive}"
    echo "Local encrypted database file is removed successfully."
  '';
in {
  ExecStartPost = ''
    ${script}/bin/pg-db-archive
  '';
}
