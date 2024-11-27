{variables, ...}: {
  services.openssh = {
    enable = true;
    ports = [22];
    settings = {
      PasswordAuthentication = false;
      AllowUsers = null;
      PermitRootLogin = "no";
    };
  };
  users.users.${variables.username}.openssh.authorizedKeys.keys = [
    "${variables.ssh.keys.user}"
  ];
}
