{ config, ... }:

{
  virtualisation.oci-containers.containers.sub-store = {
    image = "xream/sub-store:http-meta";
    networks = [ "host" ];
    environment = {
      SUB_STORE_BACKEND_API_HOST = "127.0.0.1";
      SUB_STORE_BACKEND_API_PORT = "61756";
      SUB_STORE_BACKEND_MERGE = "true";
      PORT = "13476";
      HOST = "127.0.0.1";
    };
    volumes = [
      "/var/lib/sub-store:/opt/app/data"
    ];
    environmentFiles = [ config.age.secrets.sub-store-secrets.path ];
  };
  services.nginx.virtualHosts.sub-store = {
    forceSSL = true;
    serverName = "sub-store.allenyou.wang";
    locations."/" = {
      proxyPass = "http://127.0.0.1:61756";
      recommendedProxySettings = true;
    };
    sslCertificate = "/var/ssl/allenyou.wang.crt";
    sslCertificateKey = "/var/ssl/allenyou.wang.key";
  };
}
