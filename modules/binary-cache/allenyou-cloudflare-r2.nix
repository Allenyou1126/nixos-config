{
  nix = {
    settings = {
      substituters = [
        "https://nix-cache.allenyou.wang?priority=20"
      ];
      trusted-public-keys = [
        "allenyou-nix-cache.lap-fallom.1:rKfa65SLrDQLTGEmp+c90R4vsnGgD9xFoKHrdrvJGRs="
        "allenyou-nix-cache.lax-rn-riose.1:zGDPA3NkInSSjfH5hrYBwYAIu0JyCyE9LDKl/mcDFWE="
      ];
    };
  };
}
