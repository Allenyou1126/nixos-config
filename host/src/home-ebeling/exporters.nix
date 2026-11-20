{ ... }:

{
  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "192.168.100.60";
    port = 9100;
  };
  networking.firewall.allowedTCPPorts = [ 9100 ];
}
