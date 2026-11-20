{ config, ... }:

{
  imports = [ ../../../../modules/openviking.nix ];

  # TODO(2026-11-19): python-jose 3.5.0 被 nixpkgs 标记为 insecure（CVE-2026-120459，
  # 空 HMAC key 可导致 JWT 伪造；上游 3.5.0 为最新版，暂无修复版本）。
  # 当前运行中的 openviking 已包含同一版本，且服务仅监听 127.0.0.1、auth_mode = "dev"。
  # 待 nixpkgs 撤销 insecure 标记或上游发布修复版本后，删除此例外。
  nixpkgs.config.permittedInsecurePackages = [
    "python3.13-python-jose-3.5.0"
  ];

  services.openviking = {
    enable = true;
    environmentFile = config.age.secrets.openviking-env.path;
    settings = {
      server.auth_mode = "dev";
      embedding.dense = {
        provider = "openai";
        api_base = "https://api.siliconflow.cn/v1";
        model = "BAAI/bge-m3";
        input = "text";
        dimension = 1024;
        api_key = "\${OPENVIKING_EMBEDDING_API_KEY}"; # 由 environmentFile 展开
      };
      vlm = {
        provider = "openai";
        api_key = "\${OPENVIKING_VLM_API_KEY}";
        model = "deepseek-flash";
        api_base = "https://api.deepseek.com";
        max_retries = 3;
        extra_request_body = {
          thinking = {
            type = "enabled";
          };
        };
        reasoning_effort = "high";
        media = {
          enabled = true;
          max_concurrent = 2;
          file_processing_timeout = 1800;
          file_poll_interval = 3;
          video_fps = 1.0;
        };
      };
    };
  };
}
