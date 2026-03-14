{ ... }:

{
  services.nginx.virtualHosts.zlight106-blog = {
    forceSSL = true;
    serverName = "docs.zlight106.top";
    root = "/var/www/zlight106-blog/";
    extraConfig = ''
      error_page 404 /404.html;
    '';
    locations."/" = {
      index = "index.html";
      tryFiles = "$uri $uri/index.html $uri.html$is_args$args =404";
    };
    locations."~ ^/(feed|sitemap)" = {
      extraConfig = ''
        types {}
        default_type application/xml;
      '';
    };
    sslCertificate = "/var/ssl/zlight106.top.crt";
    sslCertificateKey = "/var/ssl/zlight106.top.key";
  };
  users.extraUsers.zlight106 = {
    isNormalUser = true;
    createHome = true;
    openssh.authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFhiR8t5soqwfpcemRLTe9StCSGsD36TyJgE9PGcjJk allenyou@lap-fallom"
    ];
  };
}
