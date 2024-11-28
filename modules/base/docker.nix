{
  pkgs,
  variables,
  ...
}: {
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  users.users.${variables.username}.extraGroups = ["docker"];
  environment.systemPackages = with pkgs; [
    rootlesskit
  ];
  systemd.services.set-cap-rootlesskit = {
    description = "Set CAP_NET_BIND_SERVICE on rootlesskit binary";
    after = ["docker.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${pkgs.setcap}/bin/setcap cap_net_bind_service=ep ${pkgs.rootlesskit}/bin/rootlesskit";
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
