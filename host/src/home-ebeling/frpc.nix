{ config, pkgs, ... }:

{
  services.frp = {
    enable = true;
    role = "client";
    package = pkgs.frp;
    settings = {
      user = "home-ebeling";
      serverAddr = "frps.allenyou.top";
      serverPort = 20000;

      transport.maxPoolCount = 2000;
      transport.tcpMux = true;
      transport.tcpMuxKeepaliveInterval = 60;
      transport.tcpKeepalive = 7200;
      transport.tls.force = false;
      transport.tls.disableCustomTLSFirstByte = false;

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
      udpPacketSize = 1500;
      natholeAnalysisDataReserveHours = 168;

      proxies = [
        {
          name = "rdp";
          type = "tcp";
          localIP = "192.168.100.69";
          localPort = 3389;
          remotePort = 20089;
        }
      ];
    };
  };
}
