{
  config,
  ...
}:

{
  networking.wg-quick.interfaces = {
    lax-rn-riose = {
      autostart = true;
      table = "off";
      privateKeyFile = config.age.secrets.wireguard-private-key-file.path;
      listenPort = 50225;
      postUp = ''
        sysctl -w net.ipv6.conf.lax-rn-riose.autoconf=0
        ip addr add 172.21.89.226/27 dev lax-rn-riose
        ip addr add fdbf:b830:8a32::2/128 dev lax-rn-riose
        ip route add 172.20.0.0/14 via 172.21.89.225 dev lax-rn-riose
        ip route add 172.31.0.0/16 via 172.21.89.225 dev lax-rn-riose
        ip route add fd00::/8 via fdbf:b830:8a32::1 dev lax-rn-riose
      '';
      peers = [
        {
          endpoint = "lax-rn-riose.server.allenyou.wang:50226";
          publicKey = "4ThSZjljTkbXQp/kB0z6TB1a+4fjV41VceVl3AhnzV8=";
          allowedIPs = [
            "10.0.0.0/8"
            "172.20.0.0/14"
            "172.31.0.0/16"
            "fd00::/8"
            "fe80::/64"
          ];
        }
      ];
    };
  };
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.default.forwarding" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv4.conf.default.rp_filter" = 0;
    "net.ipv4.conf.all.rp_filter" = 0;
    "net.ipv6.conf.default.rp_filter" = 0;
    "net.ipv6.conf.all.rp_filter" = 0;
  };
  services.prometheus.exporters.wireguard = {
    enable = true;
    withRemoteIp = true;
    latestHandshakeDelay = true;
  };
  networking.firewall.extraCommands = ''
    iptables -A INPUT -s 139.196.157.228 -p tcp -m tcp --dport 9586 -j ACCEPT
  '';
  networking.firewall.allowedUDPPorts = [ 50225 ];
}
