{ config, ... }:

{
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.astrbot = {
    image = "soulter/astrbot:latest";
    networks = [ "host" ];
    environment = { };
    volumes = [
      "/var/astrbot:/AstrBot/data"
      "/etc/localtime:/etc/localtime:ro"
    ];
  };
  virtualisation.oci-containers.containers.shipyard-neo-bay = {
    image = "ghcr.io/astrbotdevs/shipyard-neo-bay:latest";
    networks = [ "bay-network" ];
    ports = [ "127.0.0.1:8114:8114" ];
    environment = {
      BAY_CONFIG_FILE = "/app/config.yaml";
      BAY_DATA_DIR = "/app/data";
    };
    environmentFiles = [ config.age.secrets.shipyard-neo-password.path ];
    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"
      "./config.yaml:/app/config.yaml:ro"
      "bay-data:/app/data"
      "bay-cargos:/var/lib/bay/cargos"
      "/etc/localtime:/etc/localtime:ro"
    ];
  };
}
