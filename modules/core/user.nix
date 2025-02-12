{
  pkgs,
  variables,
  ...
}: {
  users.users.${variables.username}.shell = pkgs.nushell;
}
