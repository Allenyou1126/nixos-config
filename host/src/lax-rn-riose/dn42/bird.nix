{
  ...
}:

{
  services.dn42.bird2 = {
    enable = true;
    ownNetwork = {
      asn = 4242421056;
      ipv4 = {
        ip = "172.21.89.225";
        cidr = "172.21.89.224/27";
      };
      ipv6 = {
        ip = "fdbf:b830:8a32:0000:0000:0000:0000:0001";
        cidr = "fdbf:b830:8a32::/48";
      };
    };
    rpkiServers = {
      akix = {
        address = "rpki.akae.re";
        port = 8282;
      };
    };
    staticSessions = {
      hkg-dog-darell = {
        neighborV4 = "172.21.89.226/32";
        neighborV6 = "fdbf:b830:8a32::2/128";
        networkInterface = "hkg-dog-darell";
      };
    };
    peeringSessions = {
      # akix = {
      #     neighborAS = 210440;
      #     networkInterface = "dn42-akix";
      #     neighborV6 = "fe80::616b:6978";
      #     multiProtocolV6 = true;
      # };
      # morecake = {
      #     neighborAS = 4242421118;
      #     networkInterface = "dn42-morecake";
      #     neighborV6 = "fe80::1118";
      #     multiProtocolV6 = true;
      # };
      darkpoint = {
        neighborAS = 4242420150;
        networkInterface = "dn42-darkpoint";
        neighborV6 = "fe80::150";
        multiProtocolV6 = true;
      };
      lantian = {
        neighborAS = 4242422547;
        networkInterface = "dn42-lantian";
        neighborV4 = "172.22.76.185";
        neighborV6 = "fe80::2547";
      };
      duststars = {
        neighborAS = 4242421771;
        networkInterface = "dn42-duststars";
        neighborV6 = "fe80::afaf:bfbf:cdcf:7";
        multiProtocolV6 = true;
      };
      lezi = {
        neighborAS = 4242423377;
        networkInterface = "dn42-lezi";
        neighborV6 = "fe80::3377";
        multiProtocolV6 = true;
      };
      potat0 = {
        neighborAS = 4242421816;
        networkInterface = "dn42-potat0";
        neighborV4 = "172.23.246.3";
        neighborV6 = "fe80::1816";
      };
      h503mc = {
        neighborAS = 4242420298;
        networkInterface = "dn42-h503mc";
        neighborV6 = "fe80::298";
        multiProtocolV6 = true;
      };
      limont = {
        neighborAS = 4242420088;
        networkInterface = "dn42-limont";
        neighborV6 = "fe80::88:2";
        multiProtocolV6 = true;
      };
      prefixlabs = {
        neighborAS = 4242421240;
        networkInterface = "dn42-prefixlabs";
        neighborV6 = "fe80::1240:3";
        multiProtocolV6 = true;
      };
      littlecow = {
        neighborAS = 4242423999;
        networkInterface = "dn42-littlecow";
        neighborV4 = "172.22.144.66";
        neighborV6 = "fe80::2:3999";
      };
      sunnet = {
        neighborAS = 4242423088;
        networkInterface = "dn42-sunnet";
        neighborV4 = "172.21.100.193";
        neighborV6 = "fdc8:dc88:ee11:193::1";
      };
      kemono42 = {
        neighborAS = 4242420358;
        networkInterface = "dn42-kemono42";
        neighborV6 = "fe80::358";
        multiProtocolV6 = true;
      };
      wolfyangfan = {
        neighborAS = 4242422034;
        networkInterface = "dn42-wolfyf";
        neighborV6 = "fe80::2034";
        multiProtocolV6 = true;
      };
    };
  };
}
