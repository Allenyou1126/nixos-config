{ ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 9100;
  };
  networking.firewall.extraCommands = ''
    iptables -A INPUT -s 106.14.99.198 -p tcp -m tcp --dport 9100 -j ACCEPT
  '';
}
