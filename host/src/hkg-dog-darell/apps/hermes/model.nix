{ ... }:

{
  services.hermes-agent.settings = {
    agent = {
      reasoning_effort = "high";
    };
    model = {
      provider = "deepseek";
      default = "deepseek-flash";
    };
    auxiliary = {
      vision = {
        provider = "deepseek";
        model = "deepseek-flash";
      };
      web_extract = {
        provider = "deepseek";
        model = "deepseek-flash";
      };
      approval = {
        provider = "deepseek";
        model = "deepseek-flash";
      };
      session_search = {
        provider = "deepseek";
        model = "deepseek-flash";
      };
      skills_hub = {
        provider = "deepseek";
        model = "deepseek-flash";
      };
      mcp = {
        provider = "deepseek";
        model = "deepseek-flash";
      };
      flush_memories = {
        provider = "deepseek";
        model = "deepseek-flash";
      };
    };
    compression = {
      enabled = true;
      summary_model = "deepseek-flash";
      summary_provider = "deepseek";
    };
  };
}
