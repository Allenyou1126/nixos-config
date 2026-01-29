{ ... }:

{
  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9090;
    globalConfig = {
      scrape_interval = "5s";
      evaluation_interval = "30s";
      external_labels = {
      };
    };
    scrapeConfigs = [
      {
        job_name = "basic";
        static_configs = [
          {
            targets = [ "127.0.0.1:9100" ];
            labels = {
              instance = "sha-ali-gaal";
              location = "sha";
            };
          }
          {
            targets = [ "172.24.24.198:9100" ];
            labels = {
              instance = "sha-ali-seldon";
              location = "sha";
            };
          }
          {
            targets = [ "74.48.162.139:9100" ];
            labels = {
              instance = "lax-rn-riose";
              location = "lax";
            };
          }
          {
            targets = [ "38.55.97.96:9100" ];
            labels = {
              instance = "hkg-dog-darell";
              location = "hkg";
            };
          }
        ];
      }
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [ "127.0.0.1:9090" ];
            labels = {
              instance = "sha-ali-gaal";
              location = "sha";
            };
          }
        ];
      }
      {
        job_name = "docker";
        static_configs = [
          {
            targets = [ "38.55.97.96:9323" ];
            labels = {
              instance = "hkg-dog-darell";
              location = "hkg";
            };
          }
        ];
      }
      {
        job_name = "coredns_dn42";
        static_configs = [
          {
            targets = [
              "74.48.162.139:9153"
            ];
            labels = {
              instance = "lax-rn-riose";
              location = "lax";
            };
          }
        ];
      }
      {
        job_name = "frps";
        static_configs = [
          {
            targets = [
              "172.24.24.198:9500" # Frps
            ];
            labels = {
              instance = "sha-ali-seldon";
              location = "sha";
            };
          }
        ];
      }
      {
        job_name = "nginx";
        static_configs = [
          {
            targets = [ "172.24.24.198:9090" ];
            labels = {
              instance = "sha-ali-seldon";
              location = "sha";
            };
          }
          {
            targets = [ "38.55.97.96:9090" ];
            labels = {
              instance = "hkg-dog-darell";
              location = "hkg";
            };
          }
        ];
      }
      {
        job_name = "bird_dn42";
        static_configs = [
          {
            targets = [ "74.48.162.139:9324" ];
            labels = {
              instance = "lax-rn-riose";
              location = "lax";
            };
          }
        ];
      }
      {
        job_name = "wireguard";
        static_configs = [
          {
            targets = [ "172.24.24.198:9586" ];
            labels = {
              instance = "sha-ali-seldon";
              location = "sha";
            };
          }
          {
            targets = [ "74.48.162.139:9586" ];
            labels = {
              instance = "lax-rn-riose";
              location = "lax";
            };
          }
        ];
      }
      {
        job_name = "website";
        params = {
          module = [ "http_2xx" ];
        };
        metrics_path = "/probe";
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "url";
          }
          {
            target_label = "__address__";
            replacement = "127.0.0.1:9115";
          }
        ];
        static_configs = [
          {
            targets = [ "https://www.allenyou.wang" ];
            labels = {
              public = "true";
              description = "Blog";
              instance = "hkg-dog-darell";
              location = "hkg";
            };
          }
          {
            targets = [ "https://image.allenyou.wang" ];
            labels = {
              public = "true";
              description = "Lsky Pro 图床";
              instance = "hkg-dog-darell";
              location = "hkg";
            };
          }
          {
            targets = [ "https://wakapi.allenyou.wang" ];
            labels = {
              description = "Wakapi";
              instance = "hkg-dog-darell";
              location = "hkg";
            };
          }
          {
            targets = [ "https://rss.allenyou.wang" ];
            labels = {
              description = "Miniflux RSS";
              instance = "hkg-dog-darell";
              location = "hkg";
            };
          }
          {
            targets = [ "https://auth.allenyou.top" ];
            labels = {
              description = "ZITADEL Auth";
              instance = "sha-ali-gaal";
              location = "sha";
            };
          }
          {
            targets = [ "https://lg.allenyou.wang" ];
            labels = {
              public = "true";
              description = "DN42 Looking Glass";
              instance = "hkg-dog-darell";
              location = "hkg";
            };
          }
          {
            targets = [ "https://grafana.allenyou.top" ];
            labels = {
              description = "Grafana";
              instance = "sha-ali-gaal";
              location = "sha";
            };
          }
          {
            targets = [ "https://portainer.allenyou.wang" ];
            labels = {
              description = "Portainer";
              instance = "hkg-dog-darell";
              location = "hkg";
            };
          }
          {
            targets = [ "https://stat.allenyou.wang" ];
            labels = {
              description = "Matomo 统计";
              instance = "hkg-dog-darell";
              location = "hkg";
            };
          }
          {
            targets = [ "https://vw.allenyou.wang" ];
            labels = {
              description = "Vaultwarden";
              instance = "hkg-dog-darell";
              location = "hkg";
            };
          }
          {
            targets = [ "https://waline.allenyou.wang" ];
            labels = {
              public = "true";
              description = "Waline 评论系统";
              instance = "hkg-dog-darell";
              location = "hkg";
            };
          }
          {
            targets = [ "https://allenyou.top" ];
            labels = {
              public = "true";
              description = "个人主页";
              instance = "zzz-ali-cdn";
              location = "global";
            };
          }
          {
            targets = [ "https://blog-oss.allenyou.top/placeholder.txt" ];
            labels = {
              public = "true";
              description = "静态资源 CDN";
              instance = "zzz-ali-cdn";
              location = "global";
            };
          }
        ];
      }
    ];
    exporters = {
      node = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9100;
      };
    };
  };
  services.blackbox-exporter = {
    enable = true;
    config = {
      modules = {
        http_2xx = {
          prober = "http";
          timeout = "5s";
          http = {
            valid_http_versions = [
              "HTTP/1.1"
              "HTTP/2.0"
            ];
            method = "GET";
            follow_redirects = true;
            fail_if_ssl = false;
            fail_if_not_ssl = false;
            preferred_ip_protocol = "ip4";
            ip_protocol_fallback = false;
          };
        };
        tcp = {
          prober = "tcp";
          timeout = "5s";
          tcp = {
            preferred_ip_protocol = "ip4";
          };
        };
        icmp = {
          prober = "icmp";
          timeout = "5s";
          icmp = {
            preferred_ip_protocol = "ip4";
          };
        };
      };
    };
  };
}
