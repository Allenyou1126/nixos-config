{ config, ... }:

{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_port = 39998;
        http_addr = "127.0.0.1";
        root_url = "https://grafana.allenyou.top";
      };
      database = {
        type = "postgres";
        host = "127.0.0.1:5432";
        user = "grafana";
        name = "grafana";
        password = "$__file{${config.age.secrets.grafana-db-password.path}}";
      };
      security = {
        secret_key = "SW2YcwTIb9zpOOhoPsMm";
      };
    };
  };
  services.nginx.virtualHosts.grafana = {
    forceSSL = true;
    serverName = "auth.allenyou.top";
    locations."/" = {
      proxyPass = "http://127.0.0.1:39998";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
    sslCertificate = "/var/ssl/allenyou.top.crt";
    sslCertificateKey = "/var/ssl/allenyou.top.key";
  };
}
