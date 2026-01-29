{ config, ... }:

{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_port = 39998;
        root_url = "https://grafana.allenyou.top";
      };
      database = {
        type = "postgres";
        host = "127.0.0.1:5432";
        user = "grafana";
        name = "grafana";
        password = "$__file{${config.age.secrets.grafana-db-password.path}}";
      };
    };
  };
}
