{ pkgs, ... }:

{
  services.nginx = {
    enable = true;
    package = pkgs.nginxMainline;
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
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [
    80
    443
  ];
}
