{ pkgs, config, ... }:

let
  dsh = pkgs.callPackage (import ../../../packages/deepseek-harness) { };

  host = "192.168.100.60";
  port = 3080;

  domain = "dsh.allenyou.top";

  home = "/var/lib/deepseek-harness";

  dsh-bin = "${dsh}/bin/dsh";
in
{
  environment.shellAliases = {
    dsh = "sudo -u deepseek-harness ${dsh-bin}";
  };
  security.sudo.extraRules = [
    {
      groups = [
        "wheels"
      ];
      runAs = "deepseek-harness";
      commands = [
        {
          command = dsh-bin;
          options = [
            "NOPASSWD"
          ];
        }
      ];
    }
    {
      groups = [
        "wheels"
      ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl ^(start|stop|restart)$ ^deepseek-harness(\.service)";
          options = [
            "NOPASSWD"
          ];
        }
      ];
    }
  ];

  users.groups.deepseek-harness = { };
  users.users.deepseek-harness = {
    isSystemUser = true;
    group = "deepseek-harness";
    home = home;
    createHome = true;
  };

  systemd.services.deepseek-harness = {
    description = "DeepSeek Harness Web UI (profile: web-server)";
    documentation = "man:systemd.special(7)";

    startLimitBurst = 5;
    startLimitIntervalSec = 300;

    after = [
      "dbus.socket"
    ];
    requires = [
      "dbus.socket"
    ];

    preStart = "
      test -d ${home}/profiles/web-server || ${dsh-bin} --profile web-server --from-default-profile web
    ";

    serviceConfig = {
      Type = "exec";
      WorkingDirectory = home;
      ExecStart = "${dsh-bin} --profile web-server --no-open --host ${host} --port ${toString port} --public-url https://${domain}/ --trusted-host ${domain}";

      Restart = "on-failure";
      RestartSec = "15";

      User = "deepseek-harness";
      Group = "deepseek-harness";

      KillSignal = "SIGTERM";
      TimeoutStopSec = "45";

      StandardOutput = "journal";
      StandardError = "journal";
      SyslogIdentifier = "deepseek-harness";

      EnvironmentFile = config.age.secrets.deepseek-harness-secret.path;
    };
    environment = {
      DSH_HOME = "${home}";
    };
  };
  networking.firewall.allowedTCPPorts = [ port ];
}
