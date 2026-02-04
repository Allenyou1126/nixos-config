{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.easytier-web;
in
{
  options.services.easytier-web = {
    enable = lib.mkEnableOption "Web API for Easytier networking";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.easytier;
      description = "Package to use for easytier-web";
    };
    apiPort = lib.mkOption {
      type = lib.types.port;
      default = 11211;
      description = "Port to listen on";
    };
    configPort = lib.mkOption {
      type = lib.types.port;
      default = 22020;
      description = "Port to listen on for config requests";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open the firewall for the API port";
    };
    configProtocol = lib.mkOption {
      type = lib.types.enum [
        "tcp"
        "udp"
        "ws"
      ];
      default = "udp";
      description = "Protocol to use for distribution of config";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.easytier-web = {
      enable = true;
      description = "Easytier Web API";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = "3";
        ExecStart = "${cfg.package}/bin/easytier-web --api-server-port ${toString cfg.apiPort} --config-server-port ${toString cfg.configPort} --config-server-protocol ${cfg.configProtocol}";

        Group = "easytier";
        User = "easytier";
      };
    };
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      cfg.apiPort
      cfg.configPort
    ];
  };
}
