{ ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 9100;
    openFirewall = true;
    firewallFilter = "-p tcp -m tcp --dport 9100 --src 172.18.63.50";
  };
}
