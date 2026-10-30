{
  pkgs,
  config,
  inputs,
  ...
}:

{
  imports = [ inputs.nokoribi-agent.nixosModules.default ];
  services.nokoribi-agent = {
    enable = true;
    environmentFile = config.age.secrets.nokoribi-env.path;

    models.main = {
      provider = "deepseek-official";
      model = "deepseek-flash";
      reasoningEffort = "high";
    };

    review = {
      fast = {
        provider = "deepseek-official";
        model = "deepseek-flash";
        reasoningEffort = "high";
      };
      strong = {
        provider = "deepseek-official";
        model = "deepseek-flash";
        reasoningEffort = "max";
      };
      timeoutMs = 30000;
      exemptTools = [
        "web_search"
        "web_fetch"
      ];
    };

    goal = {
      maxRounds = 256;
      recoveryTimeoutMs = 30000;
    };

    approval = {
      approvalTimeoutSeconds = 60;
      questionTimeoutSeconds = 300;
    };

    hosts = {
      default = "sandbox:default";
      local = {
        enable = true;
        extraPackages = [ ];
      };
      sandbox = {
        enable = true;
        packages = with pkgs; [
          git
          jq
        ];
        idleTtlMinutes = 30;
        allowRuntimePackages = true;
      };
    };

    channel.qqBot = {
      enable = true;
      appId = "102816855";
      clientSecretEnv = "NOKORIBI_QQ_BOT_CLIENT_SECRET";
      markdown = "basic";
      maxTextLength = 4500;
      maxRepliesPerReply = 4;
      c2cReplyWindowSeconds = 3600;
      groupReplyWindowSeconds = 300;
      requestTimeoutSeconds = 10;
      connectTimeoutSeconds = 30;
      activeMessageFallback = "auto";

      approvalButtons = true;

      reconnectBaseMs = 1000;
      reconnectMaxMs = 60000;
    };

    terminal = {
      enable = true;
      bashPath = "bash";
      maxResultBytes = 262144;
      sendTimeoutSeconds = 30;
      rows = 40;
      cols = 160;
      scrollbackLines = 10000;
    };

    web = {
      enable = true;
      searchProvider = "deepseek-search-api";
      fetchProvider = "deepseek-fetch-api";
      searchMaxResults = 8;
      searchMaxQueries = 4;
      searchTimeoutSeconds = 30;
      fetchTimeoutSeconds = 30;
      fetchMaxOutputChars = 200000;
    };

    prompt = {
      seedAgentsMd = true;
    };

    time = {
      zone = "Asia/Shanghai";
      contextRefreshSeconds = 60;
    };

    log.level = "info";
    sudo.enable = true;
    watchdog.intervalSeconds = 120;

    shutdown = {
      graceSeconds = 20;
      stopTimeoutSeconds = 45;
      startTimeoutSeconds = 300;
    };
  };
}
