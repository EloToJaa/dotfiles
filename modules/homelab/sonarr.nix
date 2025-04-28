{...}: {
  services.sonarr = {
    enable = true;
    user = "sonarr";
    group = "sonarr";
  };

  users.users.sonarr = {
    isSystemUser = true;
    description = "Sonarr";
    group = "sonarr";
  };
}
