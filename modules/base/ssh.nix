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
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMtWaehMf7X23uUZDY5J4fG4/exqj5jWQVaLLXloaO/g elotoja@protonmail.com"
  ];
}
