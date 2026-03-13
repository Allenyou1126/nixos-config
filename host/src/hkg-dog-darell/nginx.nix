{ pkgs, ... }:

let
  nginxPackage = pkgs.nginxMainline;
in

{
  services.nginx = {
    enable = true;
    package = nginxPackage;
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    statusPage = true;
    virtualHosts = {
      default = {
        listen = [
          {
            addr = "0.0.0.0";
            port = 80;
          }
          {
            addr = "0.0.0.0";
            port = 443;
          }
        ];
        reuseport = true;
        extraConfig = ''
          return 444;
        '';
        default = true;
        sslCertificate = "/var/ssl/allenyou.wang.crt";
        sslCertificateKey = "/var/ssl/allenyou.wang.key";
      };
    };
  };
  security.sudo.extraRules = [
    {
      users = [
        "certimate"
      ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl reload nginx";
          options = [
            "NOPASSWD"
          ];
        }
      ];
    }
  ];
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [
    80
    443
  ];
  services.prometheus.exporters.nginx = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 9090;
  };
  networking.firewall.extraCommands = ''
    iptables -A INPUT -s 139.196.157.228 -p tcp -m tcp --dport 9090 -j ACCEPT
  '';
}
