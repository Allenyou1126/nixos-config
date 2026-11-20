{ lib, pkgs, ... }:

let
  certimate = pkgs.callPackage ../../../../packages/certimate { };
in
{
  systemd.services.certimate = {
    serviceConfig = lib.mkForce {
      ExecStart = "${certimate}/bin/certimate serve --dir=/var/certimate/ --http=127.0.0.1:8090";
      Restart = lib.mkForce "always";
    };
    environment = {
      CERTIMATE_WORKFLOW_MULTIPROC = "0";
      PATH = lib.mkForce "${pkgs.coreutils}/bin:${pkgs.bash}/bin:${pkgs.openssl}/bin:${pkgs.sudo}/bin";
    };
  };
}
