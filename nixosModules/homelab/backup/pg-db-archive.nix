{
  config,
  pkgs,
  dbName,
  fileEncKey,
  backupDir,
  keepLast,
}: let
  scriptName = "pg-db-archive-${dbName}";
  script = pkgs.writeShellScriptBin scriptName ''
    ## Fail on any error:
    set -e

    ## Define the backup directory path:
    _dirBackup="${config.services.postgresqlBackup.location}"

    ## Define the path to the file to be encrypted:
    _fileBackup="''${_dirBackup}/${dbName}.sql.gz"

    _fileName="${dbName}_$(date --utc +%Y%m%dT%H%M%SZ).sql.gz.enc"

    ## Define the path to the encrypted file to be archived:
    _fileArchive="''${_dirBackup}/''${_fileName}"

    ## Encrypt the file:
    echo "Encrypting database dump..."
    ${pkgs.gnupg}/bin/gpg --symmetric --cipher-algo AES256 --batch --yes --passphrase-file ${fileEncKey} --output "''${_fileArchive}" "''${_fileBackup}"
    echo "Database file is encrypted successfully."

    ## Archive the file:
    echo "Archiving encrypted database dump..."
    mv "''${_fileArchive}" "${backupDir}/''${_fileName}"
    echo "Encrypted database file is archived successfully."

    ## Remove the local archive file:
    echo "Removing local encrypted database dump..."
    rm -f "''${_fileArchive}"
    echo "Local encrypted database file is removed successfully."

    ## Remove old backups:
    echo "Cleaning old backups..."
    ${pkgs.findutils}/bin/find "${backupDir}" -maxdepth 1 -type f -name "${dbName}_*.sql.gz.enc" \
      | ${pkgs.coreutils}/bin/sort \
      | ${pkgs.coreutils}/bin/head -n -${toString keepLast} \
      | ${pkgs.findutils}/bin/xargs -r rm -f
  '';
in {
  ExecStartPost = ''
    ${script}/bin/${scriptName}
  '';
}
