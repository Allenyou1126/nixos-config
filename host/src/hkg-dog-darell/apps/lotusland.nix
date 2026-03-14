{ ... }:

{
  services.nginx.virtualHosts.lotusland = {
    forceSSL = true;
    serverName = "lotusland.allenyou.wang";
    root = "/var/www/lotusland/";
    extraConfig = ''
      error_page 404 /404.html;
    '';
    locations."/" = {
      index = "index.html";
      tryFiles = "$uri $uri/index.html $uri.html$is_args$args =404";
    };
    sslCertificate = "/var/ssl/allenyou.wang.crt";
    sslCertificateKey = "/var/ssl/allenyou.wang.key";
  };
}
