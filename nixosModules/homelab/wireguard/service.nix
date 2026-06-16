{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.services.wireguard-netns;
in {
  options.services.wireguard-netns = {
    enable = lib.mkEnableOption {
      description = "Enable Wireguard client network namespace";
    };
    namespace = lib.mkOption {
      type = lib.types.str;
      description = "Network namespace to be created";
      default = "wg_client";
    };
    # Clean Coyote
    configFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a file with Wireguard config (not a wg-quick one!)";
      example = lib.literalExpression ''
        pkgs.writeText "wg0.conf" '''
          [Interface]
          PrivateKey = <client's privatekey>

          [Peer]
          PublicKey = <server's publickey>
          AllowedIPs = 0.0.0.0/0
          Endpoint = <server's ip>:51820
        '''
      '';
    };
    privateIP = lib.mkOption {
      type = lib.types.str;
    };
    dnsIP = lib.mkOption {
      type = lib.types.str;
    };
    hostVethAddress = lib.mkOption {
      type = lib.types.str;
      default = "169.254.67.1/30";
      description = "Address assigned to the host side of the namespace veth link";
    };
    namespaceVethAddress = lib.mkOption {
      type = lib.types.str;
      default = "169.254.67.2/30";
      description = "Address assigned to the namespace side of the namespace veth link";
    };
    hostAddress = lib.mkOption {
      type = lib.types.str;
      default = "169.254.67.1";
      description = "Host-side address reachable from inside the Wireguard namespace";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services."netns@" = {
      description = "%I network namespace";
      before = ["network.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.iproute2}/bin/ip netns add %I";
        ExecStop = "${pkgs.iproute2}/bin/ip netns del %I";
      };
    };
    environment.etc."netns/${cfg.namespace}/resolv.conf".text = "nameserver ${cfg.dnsIP}";

    systemd.services.${cfg.namespace} = {
      description = "${cfg.namespace} network interface";
      bindsTo = ["netns@${cfg.namespace}.service"];
      requires = ["network-online.target"];
      after = ["netns@${cfg.namespace}.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = with pkgs; let
          hostVeth = "wg-host";
          namespaceVeth = "wg-netns";
        in
          writers.writeBash "wg-up" ''
            set -euo pipefail

            ${iproute2}/bin/ip -n ${cfg.namespace} link del wg0 2>/dev/null || true
            ${iproute2}/bin/ip link del wg0 2>/dev/null || true
            ${iproute2}/bin/ip -n ${cfg.namespace} link del ${namespaceVeth} 2>/dev/null || true
            ${iproute2}/bin/ip link del ${hostVeth} 2>/dev/null || true

            ${iproute2}/bin/ip link add ${hostVeth} type veth peer name ${namespaceVeth}
            ${iproute2}/bin/ip link set ${namespaceVeth} netns ${cfg.namespace}
            ${iproute2}/bin/ip address add ${cfg.hostVethAddress} dev ${hostVeth}
            ${iproute2}/bin/ip -n ${cfg.namespace} address add ${cfg.namespaceVethAddress} dev ${namespaceVeth}
            ${iproute2}/bin/ip link set ${hostVeth} up
            ${iproute2}/bin/ip -n ${cfg.namespace} link set ${namespaceVeth} up

            ${iproute2}/bin/ip link add wg0 type wireguard
            ${iproute2}/bin/ip link set wg0 netns ${cfg.namespace}
            ${iproute2}/bin/ip -n ${cfg.namespace} address add ${cfg.privateIP} dev wg0
            ${iproute2}/bin/ip netns exec ${cfg.namespace} \
            ${wireguard-tools}/bin/wg setconf wg0 ${cfg.configFile}
            ${iproute2}/bin/ip -n ${cfg.namespace} link set lo up
            ${iproute2}/bin/ip -n ${cfg.namespace} link set wg0 up
            ${iproute2}/bin/ip -n ${cfg.namespace} route add default dev wg0
          '';
        ExecStop = with pkgs; let
          hostVeth = "wg-host";
        in
          writers.writeBash "wg-down" ''
            set -euo pipefail
            ${iproute2}/bin/ip -n ${cfg.namespace} route del default dev wg0 \
              2>/dev/null || true
            ${iproute2}/bin/ip -n ${cfg.namespace} link del wg0 \
              2>/dev/null || true
            ${iproute2}/bin/ip link del ${hostVeth} \
              2>/dev/null || true
          '';
      };
    };
  };
}
