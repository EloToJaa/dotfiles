{variables, ...}: {
  security.rtkit.enable = true;
  security.sudo = {
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
