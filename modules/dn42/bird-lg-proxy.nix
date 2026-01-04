{ config, lib, pkgs, ... }:

let
    cfg = config.services.dn42.bird-lg-proxy;
    bird-lg-proxy-go-pkg = pkgs.callPackage ../../pkgs/bird-lg-proxy-go.nix { };
in {
    options.services.dn42.bird-lg-proxy = {
        enable = lib.mkEnableOption "Bird-lg-proxy for DN42 networking (requires bird to be enabled)";
        port = lib.mkOption {
            type = types.port;
            default = 8000;
            description = "Port to listen on";
        };
        address = lib.mkOption {
            type = types.str;
            default = "0.0.0.0";
            description = "Address to listen on";
        };
    };

    config = lib.mkIf cfg.enable lib.mkIf config.services.dn42.bird.enable {
        systemd.services.bird-lg-proxy = {
            enable = true;
            description = "Bird-lg-proxy";
            wantedBy = [ "multi-user.target" ];
            path = with pkgs; [
                traceroute
            ];
            environment = {
                BIRD_SOCKET = "/run/bird/bird.ctl";
                BIRDLG_LISTEN = "${cfg.address}:${toString cfg.port}";
            };
            unitConfig = {
                After = "bird.service";
            };
            serviceConfig = {
                Type = "simple";
                Restart = "always";
                RestartSec = "3";
                ExecStart = lib.getExe bird-lg-proxy-go-pkg;

                # Needed by mtr and traceroute
                AmbientCapabilities = [
                    "CAP_NET_ADMIN"
                    "CAP_NET_RAW"
                ];
                CapabilityBoundingSet = [
                    "CAP_NET_ADMIN"
                    "CAP_NET_RAW"
                ];
                SystemCallFilter = [ ];

                Group = "bird";
                User = "bird";
            };
        };
    };
}