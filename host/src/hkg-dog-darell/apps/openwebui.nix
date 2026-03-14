{ config, ... }:

{
  services.open-webui = {
    enable = true;
    port = 45562;
    environment = {
      WEBUI_URL = "https://ai.allenyou.wang";

      ENABLE_LOGIN_FORM = "False";
      ENABLE_PASSWORD_AUTH = "False";
      ENABLE_OAUTH_SIGNUP = "True";
      ENABLE_OAUTH_PERSISTENT_CONFIG = "False";
      OAUTH_MERGE_ACCOUNTS_BY_EMAIL = "True";
      OAUTH_UPDATE_PICTURE_ON_LOGIN = "True";
      ENABLE_OAUTH_ID_TOKEN_COOKIE = "False";
      OAUTH_PROVIDER_NAME = "Allenyou Auth";
      OAUTH_CLIENT_ID = "364043455451709234";
      OPENID_PROVIDER_URL = "https://auth.allenyou.top/.well-known/openid-configuration";

      ENABLE_OAUTH_ROLE_MANAGEMENT = "True";

      OPENAI_API_BASE_URL = "https://api.deepseek.com";
    };
    environmentFile = config.age.secrets.openwebui-secrets.path;
  };
  services.nginx.virtualHosts.open-webui = {
    forceSSL = true;
    serverName = "ai.allenyou.wang";
    locations."/" = {
      proxyPass = "http://127.0.0.1:45562";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
    sslCertificate = "/var/ssl/allenyou.wang.crt";
    sslCertificateKey = "/var/ssl/allenyou.wang.key";
  };
}
