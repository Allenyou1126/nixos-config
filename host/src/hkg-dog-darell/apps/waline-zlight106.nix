{ config, ... }:

{
  virtualisation.oci-containers.containers.waline-zlight106 = {
    image = "lizheming/waline:latest";
    cmd = [
      "node"
      "node_modules/@waline/vercel/vanilla.js"
      "15631"
    ];
    networks = [ "host" ];
    environment = {
      DISABLE_REGION = "true";
      SERVER_URL = "https://waline.zlight106.top";
      GRAVATAR_STR = "https://blog-oss.allenyou.top/avatar/{{mail|md5}}";
      SENDER_NAME = "zlight124";
      SENDER_EMAIL = "2915423709@qq.com";
      SITE_NAME = "紫光的小图书馆";
      SITE_URL = "https://docs.zlight106.top";
      SMTP_SERVICE = "QQ";
      SMTP_USER = "2915423709@qq.com";
      TZ = "Asia/Shanghai";
      WALINE_ADMIN_MODULE_ASSET_URL = "https://blog-oss.allenyou.top/waline-admin/dist/admin.js";
      PG_DB = "waline_zlight106";
      PG_USER = "waline_zlight106";
      PG_HOST = "127.0.0.1";
      PG_PORT = "5432";
    };
    environmentFiles = [ config.age.secrets.waline-zlight106-secrets.path ];
  };
  services.nginx.virtualHosts.waline-zlight106 = {
    forceSSL = true;
    serverName = "waline.zlight106.top";
    locations."/" = {
      proxyPass = "http://127.0.0.1:15631";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
    sslCertificate = "/var/ssl/zlight106.top.crt";
    sslCertificateKey = "/var/ssl/zlight106.top.key";
  };
}
