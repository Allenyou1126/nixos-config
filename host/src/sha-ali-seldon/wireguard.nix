{
  config,
  ...
}:
let
  port = 10500;
in
{
  networking.wg-quick.interfaces = {
    wg0 = {
      privateKeyFile = config.age.secrets.wireguardPrivateKeyFile.path;
      address = [
        "192.168.103.1/24"
      ];
      listenPort = port;
      mtu = 1420;
      postUp = ''
        iptables -t nat -A POSTROUTING -s 192.168.103.0/24 -o eth0 -j MASQUERADE
        iptables -A FORWARD -i wg0 -j ACCEPT
        iptables -A FORWARD -o wg0 -j ACCEPT
      '';
      postDown = ''
        iptables -t nat -D POSTROUTING -s 192.168.103.0/24 -o eth0 -j MASQUERADE
        iptables -D FORWARD -i wg0 -j ACCEPT
        iptables -D FORWARD -o wg0 -j ACCEPT
      '';
      peers = [
        # home-hardin
        {
          presharedKeyFile = config.age.secrets.home-hardin-wireguardPresharedKeyFile.path;
          publicKey = "BMZGxqgsp4bRKHF7jOzJaPBGmB5v+39zFnHRYlerIUU=";
          allowedIPs = [
            "192.168.103.3/32"
            "192.168.100.0/24"
          ];
        }
        # lap-fallom
        {
          presharedKeyFile = config.age.secrets.lap-fallom-wireguardPresharedKeyFile.path;
          publicKey = "pGv6qXxK5Rtb4XEy6eSe1VCiR4SLX1MoIOo5yKteMkE=";
          allowedIPs = [
            "192.168.103.2/32"
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
    iptables -A INPUT -s 172.18.63.50 -p tcp -m tcp --dport 9586 -j ACCEPT
  '';
  networking.firewall.allowedUDPPorts = [ port ];
}
