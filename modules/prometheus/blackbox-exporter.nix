{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.services.blackbox-exporter;
  yaml = pkgs.formats.yaml { };
in
{
  options.services.blackbox-exporter = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Blackbox Exporter";
    };
    port = lib.mkOption {
      type = lib.types.int;
      default = 9115;
      description = "Port to listen on";
    };
    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address to listen on";
    };
    config = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Config file content";
    };
  };
  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.blackbox = {
      enable = true;
      port = cfg.port;
      listenAddress = cfg.listenAddress;
      configFile = yaml.generate "blackbox-exporter.yml" cfg.config;
    };
  };
}
