# 临时部署：选择器（chooser）网页版 https://chooser.zlight106.top
# 官方推荐的部署形态：Go 程序常驻 + Nginx 域名 HTTPS 反代。
# 回滚方式：删除本文件，并从 common.nix 的 imports 中移除对应一行即可。
{ pkgs, ... }:

let
  chooser = pkgs.buildGoModule {
    pname = "chooser";
    version = "1.4.0";
    src = pkgs.fetchFromGitHub {
      owner = "zlight-GA106";
      repo = "chooser";
      rev = "b02965234a2e2ea73d7ad97653ddc593edc58b49"; # v1.4.0
      hash = "sha256-SW6DUZ1id7vMxByXxRZsksQLpFKYzqHegsIPAbUFwqg=";
    };
    modRoot = "web";
    vendorHash = null; # 仅依赖 Go 标准库，无第三方模块
    ldflags = [
      "-s"
      "-w"
    ];
    # go.mod 的模块路径为 chooser.local/server，go install 产出的可执行文件名为
    # server，这里统一改名为 chooser，与官方部署文档保持一致。
    postInstall = ''
      mv $out/bin/server $out/bin/chooser
    '';
    meta = {
      description = "轻量的选择题练习与课堂考试工具（网页服务端）";
      homepage = "https://github.com/zlight-GA106/chooser";
      license = pkgs.lib.licenses.gpl3Only;
      mainProgram = "chooser";
    };
  };
in
{
  systemd.services.chooser = {
    description = "Chooser Web Service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      DynamicUser = true;
      ExecStart = "${chooser}/bin/chooser -addr 127.0.0.1:8088";
      Restart = "on-failure";
      RestartSec = 3;
      # 该程序无服务端存储、不写磁盘，直接套用 systemd 加固选项
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      LockPersonality = true;
      RemoveIPC = true;
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
      ];
      SystemCallArchitectures = "native";
    };
  };

  services.nginx.virtualHosts.chooser-zlight106 = {
    forceSSL = true;
    serverName = "chooser.zlight106.top";
    locations."/" = {
      proxyPass = "http://127.0.0.1:8088";
      recommendedProxySettings = true;
    };
    # 复用 zlight106.top 的通配符证书（*.zlight106.top），由 certimate 统一续期
    sslCertificate = "/var/ssl/zlight106.top.crt";
    sslCertificateKey = "/var/ssl/zlight106.top.key";
  };
}
