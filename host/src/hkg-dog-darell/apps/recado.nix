{ config, inputs, ... }:

{
  imports = [ inputs.allenyou-nur.nixosModules.recado ];
  services.recado = {
    enable = true;
    port = 28993;
    settings = {
      NODE_ENV = "production";
      LOG_LEVEL = "info";
      OIDC_ISSUER_URL = "https://auth.allenyou.top";
      OIDC_CLIENT_ID = "392035304413937458";
      OIDC_CLIENT_SECRET = "nosecret_use_pkce";
      OIDC_REDIRECT_URI = "https://recado.allenyou.wang/auth/callback";
      OIDC_ROLE_PREFIX = "recado";
      OIDC_ROLE_CLAIM = "roles";
      PUBLIC_BASE_URL = "https://recado.allenyou.wang";
      SESSION_TTL_HOURS = "168";
    };
    environmentFile = config.age.secrets.recado-env.path;
  };
  services.nginx.virtualHosts.recado = {
    forceSSL = true;
    serverName = "recado.allenyou.wang";
    locations."/" = {
      proxyPass = "http://127.0.0.1:28993";
      recommendedProxySettings = true;
    };
    sslCertificate = "/var/ssl/allenyou.wang.crt";
    sslCertificateKey = "/var/ssl/allenyou.wang.key";
  };
}
