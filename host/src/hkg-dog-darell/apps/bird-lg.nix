{ ... }:

{
  services.bird-lg.frontend = {
    enable = true;
    titleBrand = "ALLENYOU-DN42 Looking Glass";
    servers = [
      "lax-rn-riose<172.21.89.225>"
    ];
    navbar.brand = "ALLENYOU-DN42";
    domain = "";
  };
  services.nginx.virtualHosts.bird-lg = {
    forceSSL = true;
    serverName = "lg.allenyou.wang";
    locations."/" = {
      proxyPass = "http://127.0.0.1:5000";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
    sslCertificate = "/var/ssl/allenyou.wang.crt";
    sslCertificateKey = "/var/ssl/allenyou.wang.key";
  };
}
