{ config, ... }:

{
  imports = [
    ./model.nix
    ./personality.nix
  ];
  services.hermes-agent = {
    enable = true;
    environmentFiles = [ config.age.secrets.hermes-env.path ];
    addToSystemPackages = true;
    settings = {
      web.backend = "tavily";
      human_delay.mode = "natural";
      security.redact_secrets = true;
      approvals.mode = "smart";
      memory = {
        memory_enabled = true;
        user_profile_enabled = true;
      };
    };
  };
}
