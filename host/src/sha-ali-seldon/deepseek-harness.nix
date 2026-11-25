{ ... }:

{
  services.nginx.virtualHosts.deepseek-harness = {
    forceSSL = true;
    serverName = "dsh.allenyou.top";
    locations."/" = {
      proxyPass = "http://192.168.100.60:3080";
      proxyWebsockets = true;
      recommendedProxySettings = false;
      extraConfig = "
        proxy_set_header        Host $host;
        proxy_set_header        X-Real-IP $remote_addr;
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header        X-Forwarded-Proto $scheme;
        proxy_set_header        X-Forwarded-Host $host;
        proxy_set_header        X-Forwarded-Server $hostname;

        proxy_redirect          off;
        proxy_connect_timeout   3600;
        proxy_send_timeout      3600;
        proxy_read_timeout      3600;
        proxy_buffering         off;
      ";
    };
    sslCertificate = "/var/ssl/allenyou.top.crt";
    sslCertificateKey = "/var/ssl/allenyou.top.key";
  };
}
