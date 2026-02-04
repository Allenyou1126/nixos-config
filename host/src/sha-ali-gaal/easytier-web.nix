{ ... }:

{
  services.easytier-web = {
    enable = true;
    apiPort = 22021;
    configPort = 22020;
    openFirewall = false;
    configProtocol = "udp";
  };
  networking.firewall.allowedTCPPorts = [ 22020 ];
  networking.firewall.extraCommands = ''
    iptables -A INPUT -s 172.24.24.198 -p tcp -m tcp --dport 22021 -j ACCEPT
  '';
}
