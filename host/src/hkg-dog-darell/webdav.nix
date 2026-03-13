{ config, ... }:

{
  services.webdav = {
    enable = true;
    settings = {
      address = "127.0.0.1";
      port = 18237;
      auth = true;
      prefix = "/";
      directory = "/var/webdav";
      scope = "data";
      modify = true;
      rules = [ ];
      behindProxy = true;
      cors = {
        enabled = true;
        credentials = true;
        allowed_headers = [ "Depth" ];
        allowed_hosts = [ "http://localhost:8081" ];
        allowed_methods = [ "GET" ];
        exposed_headers = [
          "Content-Length"
          "Content-Range"
        ];
      };
      users = [
        {
          username = "allenyou";
          password = "{env}ENV_PASSWORD";
          directory = "/var/webdav/allenyou";
          permissions = "CURD";
        }
      ];
    };
    environmentFile = config.age.secrets.webdav-password.path;
  };

  services.nginx.virtualHosts.webdav = {
    forceSSL = true;
    serverName = "dav.allenyou.wang";
    locations."/" = {
      proxyPass = "http://127.0.0.1:18237";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
    sslCertificate = "/var/ssl/allenyou.wang.crt";
    sslCertificateKey = "/var/ssl/allenyou.wang.key";
  };
}
