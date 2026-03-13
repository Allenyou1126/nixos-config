{ config, ... }:

{
  services.miniflux = {
    enable = true;
    createDatabaseLocally = false;
    config = {
      DATABASE_URL_FILE = config.age.secrets.miniflux-database-url.path;
      OAUTH2_PROVIDER = "oidc";
      OAUTH2_CLIENT_ID = "357363864414797618";
      OAUTH2_REDIRECT_URL = "https://rss.allenyou.wang/oauth2/oidc/callback";
      OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://auth.allenyou.top";
      OAUTH2_USER_CREATION = true;
      LISTEN_ADDR = "127.0.0.1:45612";
      BASE_URL = "https://rss.allenyou.wang";
    };
  };
  services.nginx.virtualHosts.miniflux = {
    forceSSL = true;
    serverName = "rss.allenyou.wang";
    locations."/" = {
      proxyPass = "http://127.0.0.1:45612";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
    sslCertificate = "/var/ssl/allenyou.wang.crt";
    sslCertificateKey = "/var/ssl/allenyou.wang.key";
  };
}
