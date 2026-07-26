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
      platforms.qq = {
        enabled = true;
        extra = {
          markdown_support = true;
          dm_policy = "allowlist";
          allow_from = [
            "6A9A9706A3CC48AC58A1D2CADA51CF5F"
          ];
          group_policy = "disabled";
        };
      };
    };
  };
}
