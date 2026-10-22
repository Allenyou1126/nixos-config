{
  config,
  inputs,
  stdenv,
  ...
}:

{
  imports = [
    ./model.nix
    ./personality.nix
    ./deepseek-search.nix
  ];
  services.hermes-agent = {
    enable = true;
    environmentFiles = [ config.age.secrets.hermes-env.path ];
    addToSystemPackages = true;
    stateDir = "/var/lib/hermes";
    workingDirectory = "/var/lib/hermes/workspace";
    package = inputs.hermes-agent.packages.${stdenv.hostPlatform.system}.minimal;
    settings = {
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
