{ lib, pkgs, ... }:

{
  systemd.services.certimate = {
    serviceConfig = lib.mkForce {
      ExecStart = "${pkgs.allenyou-nur.certimate}/bin/certimate serve --dir /var/certimate/ --http 127.0.0.1:8090";
      Restart = lib.mkForce "always";
    };
    environment = {
      PATH = lib.mkForce "${pkgs.coreutils}/bin:${pkgs.bash}/bin:${pkgs.openssl}/bin";
    };
  };
}
