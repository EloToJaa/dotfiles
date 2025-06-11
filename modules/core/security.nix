{variables, ...}: {
  security.sudo-rs = {
    extraRules = [
      {
        users = [variables.username];
        commands = [
          {
            command = "ALL";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];
  };
  security.pam.services.hyprlock = {};
}
