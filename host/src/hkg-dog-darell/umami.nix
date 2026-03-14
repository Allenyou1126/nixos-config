{ config, ... }:

{
  services.umami = {
    enable = true;
    createPostgresqlDatabase = false;
    settings = {
      APP_SECRET_FILE = config.age.secrets.umami-app-secret.path;
      DATABASE_URL_FILE = config.age.secrets.umami-database-url.path;
      PORT = 12834;
      DISABLE_TELEMETRY = true;
    };
  };
  systemd.services.umami = {
    environment.HOME = "/var/lib/umami";
  };
  services.nginx.virtualHosts.umami = {
    forceSSL = true;
    serverName = "umami.allenyou.wang";
    locations."/" = {
      proxyPass = "http://127.0.0.1:12834";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
    sslCertificate = "/var/ssl/allenyou.wang.crt";
    sslCertificateKey = "/var/ssl/allenyou.wang.key";
  };
}
