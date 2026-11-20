# OpenViking（面向 AI Agent 的上下文数据库）的 NixOS 模块。
#
# 搬运自 github:Daaboulex/openviking-nix 的 module.nix（MIT），并按本仓库的约定重写。
# 参考模块的选项形状保留，但下列几处与 OpenViking v0.5.0 源码不符的地方都改掉了：
#
# - 服务端**不读** `OPENVIKING_HOST` / `OPENVIKING_PORT` 环境变量（那两行是死代码），
#   监听地址只能来自 `--host` / `--port` 或 ov.conf 的 `server` 段。本模块统一用
#   命令行参数，让 `services.openviking.host` / `.port` 成为唯一事实来源。
# - **配置文件是必需的**：`openviking-server` 依次查找 `--config` →
#   `OPENVIKING_CONFIG_FILE` → `~/.openviking/ov.conf` → `/etc/openviking/ov.conf`，
#   一个都找不到就以退出码 1 结束。所以 `configFile = null` 时本模块一定会生成一份
#   配置（内容来自 `settings`，默认 `{}` 也合法 —— 每个配置段都有默认值），并用
#   `--config` 传给服务端。
# - 配置加载会对 JSON 文本做 `os.path.expandvars()`：`settings` 里可以写
#   `${OPENVIKING_EMBEDDING_API_KEY}` 这类占位符，由服务的环境变量展开 —— 密钥走
#   `environmentFile`，**不要**写进 `settings`（Nix store 是全局可读的）。
# - 参考模块的 `preStart` 以服务用户身份 `mkdir` + `chown`，在全新的 `/var/lib` 下
#   必然失败；这里改用 `systemd.tmpfiles.rules`，由 root 在开机时创建。
#
# 最小用法（包默认取本仓库的 `openviking`，不需要设置 package）：
#
#   services.openviking = {
#     enable = true;
#     environmentFile = "/run/secrets/openviking.env";   # 用 sops-nix / agenix 生成
#     settings.embedding.dense = {
#       provider = "openai";
#       model = "text-embedding-3-small";
#       api_key = "\${OPENVIKING_EMBEDDING_API_KEY}";   # Nix 里 ${…} 要转义
#     };
#   };
#
# ⚠️ 认证：默认配置里没有 `server.root_api_key`，服务端会以 **dev** 模式启动（不做
# 鉴权）。只监听 127.0.0.1 时没有问题；一旦用 `host = "0.0.0.0"` / `openFirewall = true`
# 暴露到网络，请同时配置 `server.root_api_key`（同样用环境变量占位符）或 OIDC / LDAP，
# 否则任何客户端都能直接读写数据。OIDC 的 Python 依赖已随包提供；LDAP 需要
# `python-ldap`（未打包），使用 LDAP 前请自行 override 补上。
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.openviking;

  # 本仓库自带的包：flake 的 `packages.<system>.openviking` / overlay 的
  # `pkgs.allenyou-nur.openviking` 与这里取到的完全一致。
  packages = pkgs.callPackage ../packages/openviking { };

  jsonFormat = pkgs.formats.json { };

  # 生成的配置：先铺默认值，再用 lib.recursiveUpdate 合并用户的 settings（用户优先）。
  # `storage.workspace` 是数据目录；不设时默认 "./data" 会相对 WorkingDirectory 解析成
  # `<dataDir>/data`，既多一层又容易误解。
  effectiveSettings = lib.recursiveUpdate {
    storage.workspace = cfg.dataDir;
  } cfg.settings;

  # 配置文件永远存在：要么是用户显式给的，要么是上面生成到 store 的那份。
  configPath =
    if cfg.configFile != null then
      toString cfg.configFile
    else
      jsonFormat.generate "ov.conf" effectiveSettings;

  environmentFiles = lib.optional (cfg.environmentFile != null) cfg.environmentFile;

  # 进程需要做的事只有「监听端口、读写数据目录、访问模型 API」。
  # ⚠️ 不要加 MemoryDenyWriteExecute：Python 依赖的 tree-sitter / 向量引擎会用到
  # JIT 或自修改代码段，加上会直接起不来。
  hardening = {
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateTmp = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    # 默认用户的家目录就是 dataDir（在 /var/lib 下），不需要 /home；
    # 换成现有用户（例如你自己的账号）时退化成只读，便于索引家目录。
    ProtectHome = lib.mkDefault (if cfg.user == "openviking" then true else "read-only");
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectSystem = "strict";
    # AF_NETLINK：Python 枚举网卡 / 解析地址时会用到
    RestrictAddressFamilies = [
      "AF_INET"
      "AF_INET6"
      "AF_UNIX"
      "AF_NETLINK"
    ];
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    LockPersonality = true;
    SystemCallArchitectures = "native";
    CapabilityBoundingSet = [ "" ];
    AmbientCapabilities = [ "" ];
  };
in
{
  options.services.openviking = {
    enable = lib.mkEnableOption "OpenViking 上下文数据库服务端";

    package = lib.mkOption {
      type = lib.types.package;
      default = packages.openviking;
      defaultText = lib.literalExpression "allenyou-nur.openviking";
      description = ''
        服务端包。默认取本 NUR 仓库的 `openviking`，通常无需设置；
        想换（例如换成上游 flake 的产物）时用 {option}`services.openviking.package` 覆盖。
      '';
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = ''
        监听地址，以 `--host` 传给 `openviking-server`。

        该选项**覆盖** ov.conf 里的 `server.host`（源码里命令行参数优先）。
        需要对外提供 HTTP 时改成 `0.0.0.0` 或具体网卡地址，并注意文件头的认证提醒：
        默认配置是 dev 模式，不做鉴权。
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 1933;
      description = ''
        监听端口，以 `--port` 传给 `openviking-server`，并覆盖 ov.conf 里的 `server.port`。

        模块默认清空了进程的 capabilities，因此低于 1024 的端口无法直接绑定；
        确实需要时请自行在 `systemd.services.openviking.serviceConfig` 里加回
        `AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ]`。
      '';
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/openviking";
      description = ''
        数据目录。它同时是：服务的 `WorkingDirectory`、默认用户的家目录、
        以及生成配置里 `storage.workspace` 的默认值。

        目录由 {option}`systemd.tmpfiles.rules` 以 `services.openviking.user` /
        `.group` 的身份、权限 0750 创建（root 在开机时执行，不需要 preStart）。

        必须写成字符串（例如 `"/var/lib/openviking"`）：Nix 路径字面量会被复制进
        store，不能当作运行期目录用。
      '';
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/etc/openviking/ov.conf";
      description = ''
        直接使用的 ov.conf（JSON）路径，以 `--config` 传给服务端。

        为 `null`（默认）时，本模块用 {option}`services.openviking.settings` 生成
        一份配置，同样通过 `--config` 传入。两者只能选一个：同时设置 `configFile`
        和非空 `settings` 会触发断言失败。
      '';
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf jsonFormat.type;
      default = { };
      example = lib.literalExpression ''
        {
          embedding.dense = {
            provider = "openai";
            model = "text-embedding-3-small";
            api_key = "\''${OPENVIKING_EMBEDDING_API_KEY}";
          };
        }
      '';
      description = ''
        ov.conf 的声明式内容（JSON 结构，完整字段见上游 `examples/ov.conf.example`）。
        只在 `configFile = null` 时生效。

        配置加载时会对 JSON 文本做 `$VAR` / `''${VAR}` 展开，因此值里可以写环境变量
        占位符（Nix 字符串里要转义成 `"\''${VAR}"`），实际值由
        {option}`services.openviking.environmentFile` 提供：
        **密钥不要直接写在这里**（会进世界可读的 Nix store），用占位符 + 环境变量文件。

        注意：`server.host` / `server.port` 写在这里也会被
        {option}`services.openviking.host` / `.port` 的命令行参数覆盖；
        `server.workers` 等其余字段则按配置生效。
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/openviking.env";
      description = ''
        密钥 / 环境变量文件（`KEY=VALUE`），由 systemd 的 `EnvironmentFile=` 读取，
        例如用 sops-nix / agenix 生成。

        里面的变量会进入服务进程的环境：既能被 ov.conf 里的 `''${OPENVIKING_...}`
        占位符展开（见 {option}`services.openviking.settings`），也可以直接作为
        OpenViking 识别的环境变量使用（例如 `OPENVIKING_API_KEY`）。
        ⚠️ 不要把密钥放进 `settings`：那会写进世界可读的 Nix store。
      '';
    };

    readOnlyPaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "/home/alice/projects" ];
      description = ''
        额外允许服务**只读**访问的路径（映射到 systemd 的 `ReadOnlyPaths=`）。
        典型场景：以现有用户身份运行，需要索引自己的代码仓库。

        注意 `ProtectHome` 的默认值：`user = "openviking"` 时是 `true`（完全看不到
        /home）；换成别的用户时是 `"read-only"`。若要在默认用户下读取 /home 里的
        路径，需要自己把 `systemd.services.openviking.serviceConfig.ProtectHome`
        覆盖成 `"read-only"`。
      '';
    };

    readWritePaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "/srv/openviking-data" ];
      description = ''
        除 {option}`services.openviking.dataDir` 之外，额外允许**写入**的绝对路径
        （映射到 systemd 的 `ReadWritePaths=`）。例如把 `settings.storage.workspace`
        指到 dataDir 之外时，需要把那个目录加进来。
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "是否在防火墙中放行 {option}`services.openviking.port`。";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "openviking";
      description = ''
        运行服务的用户。默认的 `openviking` 系统用户由本模块创建（家目录 = `dataDir`）；
        改成已存在的用户（例如你自己的账号）时本模块不会再创建它，也不会改它的家目录。
      '';
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "openviking";
      description = ''
        运行服务的用户组。默认的 `openviking` 组由本模块创建；
        改成别的组时需要由你（或其他模块）负责创建它。
      '';
    };

    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "users" ];
      description = "服务进程的附加用户组（systemd 的 `SupplementaryGroups=`）。";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.configFile == null || cfg.settings == { };
        message = "services.openviking：configFile 与 settings 只能设置一个（configFile 已设置时 settings 必须为空）";
      }
      {
        assertion = lib.hasPrefix "/" cfg.dataDir;
        message = "services.openviking.dataDir 必须是绝对路径";
      }
    ];

    users.users.${cfg.user} = lib.mkIf (cfg.user == "openviking") {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      # 与下面 tmpfiles 的 0750 保持一致，避免两个来源把权限改来改去。
      homeMode = "0750";
      createHome = true;
      description = "OpenViking 上下文数据库";
    };

    users.groups.${cfg.group} = lib.mkIf (cfg.group == "openviking") { };

    # 数据目录由 root 在开机时创建：参考模块在 preStart 里以服务用户身份 mkdir/chown，
    # 全新的 /var/lib 下必然因权限失败。
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 ${cfg.user} ${cfg.group} -"
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.openviking = {
      description = "OpenViking 上下文数据库服务端";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      # OpenViking 会把本地 embedding 模型缓存写到 `~/.cache/openviking`、把加密根密钥
      # 写到 `~/.openviking`。以现有用户运行时 `ProtectHome = "read-only"`，这些路径
      # 不可写（日志里会出现 "Failed to generate embedding … Read-only file system"）。
      # 把 HOME 指到可写的 dataDir 后，运行期状态都落在服务自己的目录里。
      environment.HOME = cfg.dataDir;

      serviceConfig = hardening // {
        Type = "simple";
        # host / port / 配置文件都走命令行：服务端不读 OPENVIKING_HOST/PORT 环境变量，
        # 而 --config 是唯一能保证「配置一定存在」的入口（见文件头注释）。
        ExecStart = lib.escapeShellArgs [
          "${cfg.package}/bin/openviking-server"
          "--host"
          cfg.host
          "--port"
          (toString cfg.port)
          "--config"
          configPath
        ];
        WorkingDirectory = cfg.dataDir;
        User = cfg.user;
        Group = cfg.group;
        SupplementaryGroups = cfg.extraGroups;
        EnvironmentFile = environmentFiles;
        Restart = "on-failure";
        RestartSec = 5;
        ReadOnlyPaths = cfg.readOnlyPaths;
        ReadWritePaths = [ cfg.dataDir ] ++ cfg.readWritePaths;
      };
    };
  };
}
