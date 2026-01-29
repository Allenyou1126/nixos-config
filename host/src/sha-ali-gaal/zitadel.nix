{ config, ... }:

{
  services.zitadel = {
    enable = true;
    masterKeyFile = config.age.secrets.zitadel-master-key.path;
    extraSettingsPaths = [ config.age.secrets.zitadel-secret-settings.path ];
    tlsMode = "external";
    openFirewall = false;
    settings = {
      Port = 39999;
      Database.postgres = {
        Database = "zitadel";
        Host = "127.0.0.1";
        Port = 5432;
        User.SSL.Mode = "disable";
        Admin.SSL.Mode = "disable";
      };
      ExternalDomain = "auth.allenyou.top";
      ExternalPort = 443;
      ExternalSecure = true;
      TLS.Enabled = false;
    };
  };
  networking.firewall.extraCommands = ''
    iptables -A INPUT -s 172.24.24.198 -p tcp -m tcp --dport 39999 -j ACCEPT
  '';
}
