{ config, ... }:

{
  virtualisation.oci-containers.containers.open-webui = {
    image = "ghcr.io/open-webui/open-webui:main";
    networks = [ "host" ];
    volumes = [ "openwebui:/app/backend/data" ];
    environment = {
      WEBUI_URL = "https://ai.allenyou.wang";

      ENABLE_LOGIN_FORM = "False";
      ENABLE_PASSWORD_AUTH = "False";
      ENABLE_OAUTH_SIGNUP = "True";
      OAUTH_MERGE_ACCOUNTS_BY_EMAIL = "True";
      OAUTH_UPDATE_PICTURE_ON_LOGIN = "True";
      ENABLE_OAUTH_ID_TOKEN_COOKIE = "False";
      OAUTH_PROVIDER_NAME = "Allenyou Auth";
      OAUTH_CLIENT_ID = "364043455451709234";
      OPENID_PROVIDER_URL = "https://auth.allenyou.top/.well-known/openid-configuration";

      ENABLE_OAUTH_ROLE_MANAGEMENT = "True";

      OPENAI_API_BASE_URL = "https://api.deepseek.com";

      PORT = "45562";
    };
    environmentFiles = [ config.age.secrets.openwebui-secrets.path ];
  };
  services.nginx.upstreams.open-webui = {
    servers = {
      "127.0.0.1:45562" = { };
    };
    extraConfig = ''
      keepkeepalive 128;
      keepalive_timeout 1800s;
      keepalive_requests 10000;
    '';
  };
  services.nginx.virtualHosts.open-webui = {
    forceSSL = true;
    serverName = "ai.allenyou.wang";
    extraConfig = ''
      proxy_connect_timeout 86400;
      proxy_send_timeout 86400;
      proxy_read_timeout 86400;
      gzip_types text/plain text/css application/javascript image/svg+xml;
      brotli_types text/plain text/css application/javascript image/svg+xml;
    '';
    locations = {
      "/api/" = {
        proxyPass = "http://open-webui";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_connect_timeout 1800;
          proxy_send_timeout 1800;
          proxy_read_timeout 1800;

          gzip off;
          brotli off;
          proxy_buffering off;
          proxy_request_buffering off;
          proxy_cache off;
          tcp_nodelay on;
          add_header X-Accel-Buffering "no" always;
          add_header Cache-Control "no-store" always;
        '';
      };
      "~ ^/(ws/|socket\.io/)" = {
        proxyPass = "http://open-webui";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = ''
          gzip off;
          brotli off;
          proxy_buffering off;
          proxy_cache off;
          proxy_connect_timeout 86400;
          proxy_send_timeout 86400;
          proxy_read_timeout 86400;
        '';
      };
      "/static/" = {
        proxyPass = "http://open-webui";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_buffering on;
          proxy_cache_valid 200 7d;
          add_header Cache-Control "public, max-age=604800, immutable";
        '';
      };
      "/" = {
        proxyPass = "http://open-webui";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
    sslCertificate = "/var/ssl/allenyou.wang.crt";
    sslCertificateKey = "/var/ssl/allenyou.wang.key";
  };
}
