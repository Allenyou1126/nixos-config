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
  frps-pkg = pkgs.callPackage ../../../pkgs/frp.nix { };
in
{
  services.frp = {
    enable = true;
    role = "server";
    package = frps-pkg;
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

      auth.method = "token";
      auth.tokenSource = {
        type = "file";
        file = {
          path = config.age.secrets.frp-token.path;
        };
      };
      allowPorts = [
        allowedPortRange
      ];
      maxPortsPerClient = 8;
      udpPacketSize = 1500;
      natholeAnalysisDataReserveHours = 168;
    };
  };
  networking.firewall.allowedUDPPortRanges = [ (changeToFirewall allowedPortRange) ];
  networking.firewall.allowedTCPPortRanges = [ (changeToFirewall allowedPortRange) ];
  networking.firewall.allowedTCPPorts = [ listenPort ];
  networking.firewall.allowedUDPPorts = [ listenPort ];
}
