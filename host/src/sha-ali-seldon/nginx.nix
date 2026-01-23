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
      };
    };
  };
  users = {
    certimate = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP2HKtf/h6LCGS9s29pzRNP2ov3xpssw2Gh9CT8A4Fa8 certimate@sha-ali-seldon"
      ];
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
          command = "${nginxPackage}/bin/nginx -s reload";
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

}
