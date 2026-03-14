{ ... }:

{
  services.nginx.virtualHosts.blog = {
    forceSSL = true;
    serverName = "www.allenyou.wang";
    serverAliases = [ "allenyou.wang" ];
    root = "/var/www/blog/";
    extraConfig = ''
      error_page 404 /404.html;
      if ($host != www.allenyou.wang) {
        rewrite /(.*) https://www.allenyou.wang/$1 permanent;
      }
    '';
    locations."/" = {
      index = "index.html";
      tryFiles = "$uri $uri/index.html $uri.html$is_args$args =404";
    };
    sslCertificate = "/var/ssl/allenyou.wang.crt";
    sslCertificateKey = "/var/ssl/allenyou.wang.key";
  };
}
