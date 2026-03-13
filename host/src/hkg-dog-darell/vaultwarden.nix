{ config, ... }:

{
  services.vaultwarden = {
    enable = true;
    domain = "vw.allenyou.wang";
    dbBackend = "postgresql";
    config = {
      PUSH_ENABLED = true;
      ROCKET_PROFILE = "release";
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 45254;
      SHOW_PASSWORD_HINT = true;
      SIGNUPS_ALLOWED = true;
      INVITATIONS_ALLOWED = false;

      # SSO Configuration
      SSO_ENABLED = true;
      SSO_ONLY = true;
      SSO_SIGNUPS_MATCH_EMAIL = false;
      SSO_PKCE = true;
      SSO_AUTHORITY = "https://auth.allenyou.top";
      SSO_CLIENT_ID = "362406448245849906";
      SSO_AUDIENCE_TRUSTED = "^$357361471966953266$";
      SSO_CLIENT_SECRET = "362406448245849906";
      SSO_SCOPES = "openid profile email offline_access";

      # SMTP Configuration
      SMTP_HOST = "smtp.fastmail.com";
      SMTP_PORT = 465;
      SMTP_SECURITY = "force_tls";
      SMTP_FROM = "vaultwarden@allenyou.wang";
      SMTP_USER = "i@allenyou.wang";
    };
    environmentFile = config.age.secrets.vaultwarden-secrets.path;
  };
  services.nginx.virtualHosts.vaultwarden = {
    forceSSL = true;
    serverName = "vw.allenyou.wang";
    locations."/" = {
      proxyPass = "http://127.0.0.1:45254";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
    sslCertificate = "/var/ssl/allenyou.wang.crt";
    sslCertificateKey = "/var/ssl/allenyou.wang.key";
  };
}
