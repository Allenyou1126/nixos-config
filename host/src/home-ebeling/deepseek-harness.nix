{ pkgs, config, ... }:

let
  dsh = pkgs.callPackage (import ../../../packages/deepseek-harness) { };

  host = "192.168.100.60";
  port = 3080;

  domain = "dsh.allenyou.top";

  home = "/var/lib/deepseek-harness";
  dsh-home = "${home}/.dsh";

  dsh-bin = "${dsh}/bin/dsh";

  dsh-sudo = pkgs.writeShellScript "dsh-sudo" ''
    export HOME=${home}
    export DSH_HOME=${dsh-home}
    export PATH=/run/current-system/sw/bin:$PATH
    exec ${dsh}/bin/dsh "$@"
  '';
in
{
  environment.systemPackages = with pkgs; [
    pnpm
    gh
  ];

  environment.shellAliases = {
    dsh = "sudo -u deepseek-harness ${dsh-sudo}";
  };
  security.sudo.extraRules = [
    {
      groups = [
        "wheel"
      ];
      runAs = "deepseek-harness";
      commands = [
        {
          command = toString dsh-sudo;
          options = [
            "NOPASSWD"
          ];
        }
      ];
    }
    {
      groups = [
        "wheel"
      ];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl ^(start|stop|restart) deepseek-harness(\\.service)?$";
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

    startLimitBurst = 5;
    startLimitIntervalSec = 300;

    after = [
      "dbus.socket"
    ];
    requires = [
      "dbus.socket"
    ];

    preStart = "
      test -d ${dsh-home}/profiles/web-server || ${dsh-bin} --profile web-server --from-default-profile web --no-open --dump-config
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
      DSH_HOME = "${dsh-home}";
      HOME = "${home}";
      SHELL = "${pkgs.bash}/bin/bash";
      LANG = "C.UTF-8";
    };

    path = with pkgs; [
      bash
      tmux
      pnpm
      git
      gawk

      diffutils
      patch

      gnutar
      gzip
      xz
      bzip2
      zstd
      unzip
      zip

      procps
      psmisc
      util-linux

      file
      which

      wget
      curl
      gh

      ripgrep
      fd
      jq
      yq-go

      openssh
      rsync
      python3

      gnupg
      git-lfs

      tree

      nix

      openssl

      iproute2
    ];
  };
  networking.firewall.allowedTCPPorts = [ port ];
}
