{ config, pkgs, ... }:

let
  listenPort = 20000;
  allowedPortRange = {
    start = 20001;
    end = 20099;
  };
  changeToFirewall = portRange: {
    from = portRange.start;
    to = portRange.end;
  };
in
{
  services.frp = {
    package = pkgs.frp;
    instances."default" = {
      enable = true;
      role = "server";
      environmentFiles = [
        config.age.secrets.frp-token.path
      ];
      settings = {
        bindAddr = "0.0.0.0";
        bindPort = listenPort;
        quicBindPort = listenPort;

        transport.maxPoolCount = 2000;
        transport.tcpMux = true;
        transport.tcpMuxKeepaliveInterval = 60;
        transport.tcpKeepalive = 7200;
        transport.tls.force = false;

        log.to = "/dev/stdout";
        log.level = "info";
        log.disablePrintColor = false;

        webServer.addr = "127.0.0.1";
        webServer.port = 9500;
        enablePrometheus = true;

        auth.method = "token";
        auth.token = "{{ .Envs.FRP_TOKEN }}";
        allowPorts = [
          allowedPortRange
        ];
        maxPortsPerClient = 8;
        udpPacketSize = 1500;
        natholeAnalysisDataReserveHours = 168;
      };
    };
  };
  networking.firewall.allowedUDPPortRanges = [ (changeToFirewall allowedPortRange) ];
  networking.firewall.allowedTCPPortRanges = [ (changeToFirewall allowedPortRange) ];
  networking.firewall.allowedTCPPorts = [ listenPort ];
  networking.firewall.allowedUDPPorts = [ listenPort ];
}
