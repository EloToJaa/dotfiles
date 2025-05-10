{variables, ...}: {
  security.sudo-rs = {
    enable = true;
    extraRules = [
      {
        users = ["${variables.username}"];
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
