{ config, ... }:

{
  services.nginx.virtualHosts.deepseek-harness = {
    forceSSL = true;
    serverName = "dsh.allenyou.top";
    locations."/" = {
      proxyPass = "http://192.168.100.60:3080";
      proxyWebsockets = true;
      recommendedProxySettings = false;
      extraConfig = "
        auth_request /oauth2/auth;
        error_page 401 = @oauth2_sign;

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
        proxy_http_version      1.1;
        proxy_buffering         off;

        include ${config.age.secrets.deepseek-harness-secret.path};
      ";
    };
    locations."/oauth2/" = {
      proxyPass = "http://127.0.0.1:4180";
      recommendedProxySettings = true;
      extraConfig = ''
        proxy_set_header X-Auth-Request-Redirect $request_uri;
      '';
    };
    locations."/oauth2/auth" = {
      proxyPass = "http://127.0.0.1:4180";
      recommendedProxySettings = true;
      extraConfig = ''
        proxy_set_header Content-Length   "";
        proxy_pass_request_body           off;
      '';
    };
    locations."@oauth2_signin" = {
      return = "302 /oauth2/sign_in?rd=$scheme://$host$request_uri";
    };
    sslCertificate = "/var/ssl/allenyou.top.crt";
    sslCertificateKey = "/var/ssl/allenyou.top.key";
  };

  services.oauth2-proxy = {
    enable = true;
    provider = "oidc";
    oidcIssuerUrl = "https://auth.allenyou.top";
    clientID = "400428523782740166";
    cookie.secretFile = config.age.secrets.dsh-oauth2-cookie-secret.path;
    cookie.secure = true;
    cookie.expire = "168h";
    redirectURL = "https://dsh.allenyou.top/oauth2/callback";
    reverseProxy = true;
    trustedProxyIP = [ "127.0.0.1" ];
    scope = "openid profile email";
    extraConfig.skip-provider-button = true;
  };
}
