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
        job_name = "sha-ali-gaal";
        static_configs = [
          {
            targets = [
              "127.0.0.1:9100" # Node Exporter
              "127.0.0.1:9115" # Blackbox Exporter
              "127.0.0.1:9090" # Prometheus
            ];
          }
        ];
      }
      {
        job_name = "sha-ali-seldon";
        static_configs = [
          {
            targets = [
              "172.24.24.198:9100" # Node Exporter
              "172.24.24.198:9090" # Nginx Exporter
              "172.24.24.198:9500" # Frps
              "172.24.24.198:9586" # Wireguard Exporter
            ];
          }
        ];
      }
      {
        job_name = "lax-rn-riose";
        static_configs = [
          {
            targets = [
              "139.196.157.228:9100" # Node Exporter
              "139.196.157.228:9324" # Bird Exporter
              "139.196.157.228:9586" # Wireguard Exporter
              "139.196.157.228:9153" # CoreDNS Exporter for allenyou.dn42
              "139.196.157.228:9154" # CoreDNS Exporter for 172.21.89.224/27
              "139.196.157.228:9155" # CoreDNS Exporter for 224/27.89.21.172.in-addr.arpa
              "139.196.157.228:9156" # CoreDNS Exporter for fdbf:b830:8a32::/48
            ];
          }
        ];
      }
      {
        job_name = "blackbox";
        scrape_interval = "5s";
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
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement = "127.0.0.1:9115";
          }
        ];
        static_configs = [
          {
            targets = [
              "https://www.allenyou.wang"
              "https://image.allenyou.wang"
              "https://wakapi.allenyou.wang"
              "https://rss.allenyou.wang"
              "https://auth.allenyou.top"
              "https://lg.allenyou.wang"
              "https://grafana.allenyou.wang"
              "https://portainer.allenyou.wang"
              "https://stat.allenyou.wang"
              "https://vw.allenyou.wang"
              "https://waline.allenyou.wang"
              "https://allenyou.top"
              "https://blog-oss.allenyou.top/placeholder.txt"
            ];
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
