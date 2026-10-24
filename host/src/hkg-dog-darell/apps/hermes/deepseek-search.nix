{ pkgs, ... }:

{
  services.hermes-agent = {
    settings = {
      plugins.enabled = [ "web-deepseek-native" ];
      web.search_backend = "deepseek_native";
      web.extract_backend = "search_backend";
    };
    extraPlugins = [
      (pkgs.fetchFromGitHub {
        owner = "Visol-456";
        repo = "hermes-deepseek-search-provider";
        rev = "5c7756be43d539a6bade2f22e137e8b3f32bfe42";
        hash = "sha256-EU4pz/p8vzGWF4JS5/g4jFDt9CWEuzy7bS7GQ3Kz4Q4=";
      })
    ];
  };
}
