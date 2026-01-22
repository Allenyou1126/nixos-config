{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.dn42.bird-lg-proxy;
in
{
  options.services.dn42.bird-lg-proxy = {
    enable = lib.mkEnableOption "Bird-lg-proxy for DN42 networking (requires bird to be enabled)";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.bird-lg;
      description = "Package to use for bird-lg-proxy";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 8000;
      description = "Port to listen on";
    };
    address = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Address to listen on";
    };
  };

  config = lib.mkIf (cfg.enable && config.services.dn42.bird2.enable) {
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
        ExecStart = "${cfg.package}/bin/proxy";

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
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
