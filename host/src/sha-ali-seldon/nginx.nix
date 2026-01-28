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
            extraParameters = [
              "default_server"
            ];
          }
        ];
        reuseport = true;
        root = "/var/www/html";
        serverName = "homepage-cdn-origin.allenyou.top";
        locations = {
          "/" = {
            tryFiles = "$uri $uri/ =404";
          };
        };
        extraConfig = ''
          if ($http_aliyun_cdn_source_allenyou != 'true') {
            return 444;
          }
        '';
        default = true;
      };
      zitadel = {
        forceSSL = true;
        serverName = "auth.allenyou.top";
        locations."/" = {
          proxyPass = "http://172.18.63.50:39999";
          proxyWebsockets = true;
          recommendedProxySettings = true;
        };
        sslCertificate = "/var/ssl/allenyou.top.crt";
        sslCertificateKey = "/var/ssl/allenyou.top.key";
      };
    };
  };
  users.users = {
    certimate = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP2HKtf/h6LCGS9s29pzRNP2ov3xpssw2Gh9CT8A4Fa8 certimate@sha-ali-seldon"
      ];
      shell = pkgs.bashInteractive;
      isSystemUser = true;
      group = "nginx";
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
    iptables -A INPUT -s 172.18.63.50 -p tcp -m tcp --dport 9090 -j ACCEPT
  '';
}
