{ inputs, config, ... }:

{
  imports = [ inputs.allenyou-nur.nixosModules.openviking ];
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
