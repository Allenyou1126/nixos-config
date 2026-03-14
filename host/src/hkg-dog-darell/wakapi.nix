{ config, ... }:

{
  services.allenyou.wakapi = {
    enable = true;
    database = {
      dialect = "postgres";
    };
    settings = {
      env = "production";
      quick_start = false;
      skip_migrations = false;
      enable_pprof = false;

      server = {
        listen_ipv4 = "127.0.0.1";
        listen_ipv6 = "-";
        listen_socket = "-";
        timeout_sec = 30;
        port = 45123;
        base_path = "/";
        public_url = "https://wakapi.allenyou.wang";
      };

      app = {
        leaderboard_enabled = true;
        leaderboard_scope = "7_days";
        leaderboard_generation_time = "0 0 6 * * *,0 0 18 * * *";
        leaderboard_require_auth = false;
        aggregation_time = "0 15 2 * * *";
        report_time_weekly = "0 0 18 * * 5";
        data_cleanup_time = "0 0 6 * * 0";
        optimize_database_time = "0 0 8 1 * *";
        inactive_days = 7;
        import_enabled = true;
        import_backoff_min = 5;
        import_max_rate = 24;
        import_batch_size = 50;
        heartbeat_max_age = "4320h";
        data_retention_months = -1;
        max_inactive_months = 12;
        warm_caches = true;
        custom_languages = {
          vue = "Vue";
          jsx = "JSX";
          tsx = "TSX";
          cjs = "JavaScript";
          ipynb = "Python";
          svelte = "Svelte";
          astro = "Astro";
        };
        canonical_language_names = {
          "java" = "Java";
          "ini" = "INI";
          "xml" = "XML";
          "jsx" = "JSX";
          "tsx" = "TSX";
          "php" = "PHP";
          "yaml" = "YAML";
          "toml" = "TOML";
          "sql" = "SQL";
          "css" = "CSS";
          "scss" = "SCSS";
          "jsp" = "JSP";
          "svg" = "SVG";
          "csv" = "CSV";
        };

        avatar_url_template = "https://blog-oss.allenyou.top/avatar/{email_hash}?s=100";

        date_format = "2006-01-02";
        datetime_format = "2006-01-02 15:04";

        db = {
          host = "127.0.0.1";
          port = 5432;
          dialect = "postgres";
          user = "wakapi";
          name = "wakapi";
        };

        security = {
          allow_signup = true;
          signup_captcha = false;
          invite_codes = true;
          disable_frontpage = true;
          expose_metrics = false;
          trusted_header_auth = false;
          trusted_header_auth_key = "Remote-User";
          trusted_header_auth_allow_signup = false;
          trust_reverse_proxy_ips = [ "127.0.0.1" ];
          signup_max_rate = "5/1h";
          login_max_rate = "10/1m";
          password_reset_max_rate = "5/1h";
          oidc = [
            {
              name = "zitadel";
              display_name = "Allenyou Auth";
              client_id = "357364480843267890";
              endpoint = "https://auth.allenyou.top";
            }
          ];
          insecure_cookies = true;
        };

        mail = {
          enabled = true;
          provider = "smtp";
          sender = "Allenyou-Wakapi <wakapi@allenyou.wang>";
          smtp = {
            host = "smtp.fastmail.com";
            port = 465;
            username = "i@allenyou.wang";
            tls = true;
          };
        };
      };
    };
    environmentFiles = [ config.age.secrets.wakapi-secrets.path ];
  };
  services.nginx.virtualHosts.wakapi = {
    forceSSL = true;
    serverName = "wakapi.allenyou.wang";
    locations."/" = {
      proxyPass = "http://127.0.0.1:45123";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
    sslCertificate = "/var/ssl/allenyou.wang.crt";
    sslCertificateKey = "/var/ssl/allenyou.wang.key";
  };
}
