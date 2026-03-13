{ lib, pkgs, ... }:

{
  systemd.services.certimate.serviceConfig = lib.mkForce {
    ExecPreStart = "mkdir -p /var/certimate/";
    ExecStart = "${pkgs.allenyou-nur.certimate}/bin/certimate serve --dir /var/certimate/ --http 127.0.0.1:8090";
    Restart = lib.mkForce "always";
    User = "certimate";
  };
}
