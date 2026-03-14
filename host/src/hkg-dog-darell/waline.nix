{ config, ... }:

{
  virtualisation.oci-containers.containers.waline = {
    image = "lizheming/waline:latest";
    cmd = [
      "node"
      "node_modules/@waline/vercel/vanilla.js"
      "15656"
    ];
    networks = [ "host" ];
    environment = {
      DISABLE_REGION = "true";
      GRAVATAR_STR = "https://blog-oss.allenyou.top/avatar/{{mail|md5}}";
      MARKDOWN_HIGHLIGHT = "false";
      SENDER_NAME = "Allen You";
      SENDER_EMAIL = "comment-notify@allenyou.wang";
      AUTHOR_EMAIL = "i@allenyou.wang";
      SERVER_URL = "https://waline.allenyou.wang";
      SITE_NAME = "秋实-Allenyou的小窝";
      SITE_URL = "https://www.allenyou.wang";
      SMTP_HOST = "smtp.fastmail.com";
      SMTP_PORT = "465";
      SMTP_USER = "i@allenyou.wang";
      SMTP_SECURE = "true";
      TZ = "Asia/Shanghai";
      WALINE_ADMIN_MODULE_ASSET_URL = "https://blog-oss.allenyou.top/waline-admin/dist/admin.js";
      PG_DB = "waline";
      PG_USER = "waline";
      PG_HOST = "127.0.0.1";
      PG_PORT = "5432";
    };
    environmentFiles = [ config.age.secrets.waline-secrets.path ];
  };
  services.nginx.virtualHosts.waline = {
    forceSSL = true;
    serverName = "waline.allenyou.wang";
    locations."/" = {
      proxyPass = "http://127.0.0.1:15656";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
    sslCertificate = "/var/ssl/allenyou.wang.crt";
    sslCertificateKey = "/var/ssl/allenyou.wang.key";
  };
}
