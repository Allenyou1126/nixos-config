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
  networking.firewall.extraCommands = ''
    iptables -A INPUT -s 172.24.24.198 -p tcp -m tcp --dport 39998 -j ACCEPT
  '';
}
