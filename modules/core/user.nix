{
  pkgs,
  variables,
  lib,
  ...
}: {
  users.users.${variables.username}.shell = lib.mkForce pkgs.nushell;
  programs.nushell.enable = true;
}
