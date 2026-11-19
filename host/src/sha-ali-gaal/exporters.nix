{ ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 9100;
  };
  networking.firewall.extraCommands = ''
    iptables -A INPUT -s 172.24.24.198 -p tcp -m tcp --dport 9100 -j ACCEPT
  '';
}
