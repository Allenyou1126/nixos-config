{
  ...
}:

let
  serial = 2025123100;
in
{
  services.dn42.coredns = {
    enable = true;
    zoneFiles = [
      {
        fileName = "ALLENYOU-DN42-V4.zone";
        zone = "224/27.89.21.172.in-addr.arpa.";
        defaultTtl = 300;
        soa = {
          mname = "ns1.allenyou.dn42.";
          rname = "i.allenyou.wang.";
          serial = serial;
          refresh = 3600;
          retry = 3600;
          expire = 1209600;
          minimum = 600;
        };
        records = [
          {
            name = "@";
            ttl = 600;
            class = "IN";
            type = "NS";
            value = "ns1.allenyou.dn42.";
          }
          {
            name = "225";
            ttl = 600;
            class = "IN";
            type = "PTR";
            value = "lax-rn-riose.server.allenyou.dn42.";
          }
          {
            name = "226";
            ttl = 600;
            class = "IN";
            type = "PTR";
            value = "hkg-dog-darell.server.allenyou.dn42.";
          }
          {
            name = "225.89.21.172.in-addr.arpa.";
            ttl = 600;
            class = "IN";
            type = "CNAME";
            value = "225.224/27.89.21.172.in-addr.arpa.";
          }
          {
            name = "226.89.21.172.in-addr.arpa.";
            ttl = 600;
            class = "IN";
            type = "CNAME";
            value = "226.224/27.89.21.172.in-addr.arpa.";
          }
        ];
      }
      {
        fileName = "ALLENYOU-DN42-V6.zone";
        zone = "2.3.a.8.0.3.8.b.f.b.d.f.ip6.arpa.";
        defaultTtl = 300;
        soa = {
          mname = "ns1.allenyou.dn42.";
          rname = "i.allenyou.wang.";
          serial = serial;
          refresh = 3600;
          retry = 3600;
          expire = 1209600;
          minimum = 600;
        };
        records = [
          {
            name = "@";
            ttl = 600;
            class = "IN";
            type = "NS";
            value = "ns1.allenyou.dn42.";
          }
          {
            name = "1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0";
            ttl = 600;
            class = "IN";
            type = "PTR";
            value = "lax-rn-riose.server.allenyou.dn42.";
          }
          {
            name = "2.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0";
            ttl = 600;
            class = "IN";
            type = "PTR";
            value = "hkg-dog-darell.server.allenyou.dn42.";
          }
        ];
      }
      {
        fileName = "allenyou.dn42.zone";
        zone = "allenyou.dn42.";
        defaultTtl = 300;
        soa = {
          mname = "ns1.allenyou.dn42.";
          rname = "i.allenyou.wang.";
          serial = serial;
          refresh = 3600;
          retry = 3600;
          expire = 1209600;
          minimum = 600;
        };
        records = [
          {
            name = "@";
            ttl = 600;
            class = "IN";
            type = "NS";
            value = "ns1.allenyou.dn42.";
          }
          {
            name = "ns1";
            ttl = 600;
            class = "IN";
            type = "A";
            value = "172.21.89.225";
          }
          {
            name = "ns1";
            ttl = 600;
            class = "IN";
            type = "AAAA";
            value = "fdbf:b830:8a32::1";
          }
          {
            name = "lax-rn-riose.server";
            ttl = 600;
            class = "IN";
            type = "A";
            value = "172.21.89.225";
          }
          {
            name = "lax-rn-riose.server";
            ttl = 600;
            class = "IN";
            type = "AAAA";
            value = "fdbf:b830:8a32::1";
          }
          {
            name = "hkg-dog-darell.server";
            ttl = 600;
            class = "IN";
            type = "A";
            value = "172.21.89.226";
          }
          {
            name = "hkg-dog-darell.server";
            ttl = 600;
            class = "IN";
            type = "AAAA";
            value = "fdbf:b830:8a32::2";
          }
          {
            name = "@";
            ttl = 600;
            class = "IN";
            type = "CNAME";
            value = "lax-rn-riose.server.allenyou.dn42.";
          }
          {
            name = "la.server";
            ttl = 600;
            class = "IN";
            type = "CNAME";
            value = "lax-rn-riose.server.allenyou.dn42.";
          }
          {
            name = "hk.server";
            ttl = 600;
            class = "IN";
            type = "CNAME";
            value = "hkg-dog-darell.server.allenyou.dn42.";
          }
        ];
      }
    ];
    serverBlocks = [
      {
        zone = "allenyou.dn42";
        plugins = [
          "log"
          [
            "file"
            "/etc/coredns/zones/allenyou.dn42.zone"
          ]
          [
            "prometheus"
            "0.0.0.0:9153"
          ]
        ];
      }
      {
        zone = "172.21.89.224/27";
        plugins = [
          "log"
          [
            "file"
            "/etc/coredns/zones/ALLENYOU-DN42-V4.zone"
          ]
          [
            "prometheus"
            "0.0.0.0:9154"
          ]
        ];
      }
      {
        zone = "224/27.89.21.172.in-addr.arpa";
        plugins = [
          "log"
          [
            "file"
            "/etc/coredns/zones/ALLENYOU-DN42-V4.zone"
          ]
          [
            "prometheus"
            "0.0.0.0:9155"
          ]
        ];
      }
      {
        zone = "fdbf:b830:8a32::/48";
        plugins = [
          "log"
          [
            "file"
            "/etc/coredns/zones/ALLENYOU-DN42-V6.zone"
          ]
          [
            "prometheus"
            "0.0.0.0:9156"
          ]
        ];
      }
    ];
  };
  networking.firewall.extraCommands = ''
    iptables -A INPUT -s 139.196.157.228 -p tcp -m tcp --dport 9153:9156 -j ACCEPT
  '';
}
