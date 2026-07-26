{ ... }:

{
  services.hermes-agent.settings = {
    custom_providers = [
      {
        name = "xcpc-ai";
        base_url = "https://xcpcai.com/v1";
        models = {
          "gpt-5.6-sol" = {
            context_length = 400000;
          };
          "gpt-5.6-luna" = {
            context_length = 400000;
          };
        };
        api_key = "\${OPENAI_API_KEY}";
        api_mode = "chat_completions";
      }
    ];
    agent = {
      reasoning_effort = "max";
    };
    model = {
      provider = "xcpc-ai";
      default = "gpt-5.6-sol";
    };
    auxiliary = {
      vision = {
        provider = "xcpc-ai";
        model = "gpt-5.6-luna";
      };
      web_extract = {
        provider = "xcpc-ai";
        model = "gpt-5.6-luna";
      };
      approval = {
        provider = "xcpc-ai";
        model = "gpt-5.6-luna";
      };
      session_search = {
        provider = "xcpc-ai";
        model = "gpt-5.6-luna";
      };
      skills_hub = {
        provider = "xcpc-ai";
        model = "gpt-5.6-luna";
      };
      mcp = {
        provider = "xcpc-ai";
        model = "gpt-5.6-luna";
      };
      flush_memories = {
        provider = "xcpc-ai";
        model = "gpt-5.6-luna";
      };
    };
    compression = {
      enabled = true;
      summary_model = "gpt-5.6-luna";
      summary_provider = "main";
    };
  };
}
