{ config, lib, pkgs, ... }:

let
    cfg = config.services.dn42.bird2;
    types = rec {
        ownNetwork = lib.types.submodule {
            options = {
                asn = lib.mkOption {
                    type = lib.types.int;
                    description = "The ASN of your own network.";
                };
                ipv4 = lib.mkOption {
                    type = networkConfig;
                    description = "IPv4 Configuration of your own network.";
                };
                ipv6 = lib.mkOption {
                    type = networkConfig;
                    description = "IPv6 Configuration of your own network.";
                };
            };
        };
        networkConfig = lib.types.submodule {
            options = {
                ip = lib.mkOption {
                    type = lib.types.str;
                    description = "The IP address of this server.";
                };
                cidr = lib.mkOption {
                    type = lib.types.str;
                    description = "Your IP address range in the CIDR form.";
                };
            };
        };
        peeringSession = lib.types.submodule {
            options = {
                neighborAS = lib.mkOption {
                    type = lib.types.int;
                    description = "The ASN of the peer network.";
                };
                networkInterface = lib.mkOption {
                    type = lib.types.str;
                    description = "The network interface to create BGP Session over.";
                };
                neighborV4 = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                    description = "The IPv4 address of your neighbor to create BGP Session via. Leave it as null will disable IPv4 BGP Session.";
                };
                neighborV6 = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                    description = "The IPv6 address of your neighbor to create BGP Session via. Leave it as null will disable IPv6 BGP Session.";
                };
                multiProtocolV4 = lib.mkOption {
                    type = lib.types.bool;
                    default = false;
                    description = "Whether to enable MP-BGP and allow route transfer over IPv4 BGP Session.";
                };
                multiProtocolV6 = lib.mkOption {
                    type = lib.types.bool;
                    default = false;
                    description = "Whether to enable MP-BGP and allow route transfer over IPv6 BGP Session.";
                };
            };
        };
        staticSession = lib.types.submodule {
            options = {
                networkInterface = lib.mkOption {
                    type = lib.types.str;
                    description = "The network interface to create BGP Session over.";
                };
                neighborV4 = lib.mkOption {
                    type = lib.types.str;
                    default = null;
                    description = "The IPv4 address of your neighbor to create static Session via.";
                };
                neighborV6 = lib.mkOption {
                    type = lib.types.str;
                    default = null;
                    description = "The IPv6 address of your neighbor to create static Session via.";
                };
            };
        };
        rpkiServer = lib.types.submodule {
            options = {
                address = lib.mkOption {
                    type = lib.types.str;
                    description = "The address of RPKI server.";
                };
                port = lib.mkOption {
                    type = lib.types.port;
                    description = "The port of RPKI server.";
                };
                retry = lib.mkOption {
                    type = lib.types.int;
                    default = 90;
                    description = "The retry interval of RPKI server.";
                };
                refresh = lib.mkOption {
                    type = lib.types.int;
                    default = 900;
                    description = "The refresh interval of RPKI server.";
                };
                expire = lib.mkOption {
                    type = lib.types.int;
                    default = 172800;
                    description = "The expire interval of RPKI server.";
                };
            };
        };
    };

    mkV4Session = name: peer: let
        sessionHead = "protocol bgp dn42_${name}_v4 from dn42peers {\n";
        sessionBody = ''
    neighbor ${peer.neighborV4} % ${peer.networkInterface} as ${builtins.toString peer.neighborAS};
    direct;
        '';
        sessionEnd = "};\n";
        mpBgpPart = if peer.multiProtocolV4 then "" else ''
    ipv6 {
        import none;
        export none;
    };
        '';
    in sessionHead + sessionBody + mpBgpPart + sessionEnd;

    mkV6Session = name: peer: let
        sessionHead = "protocol bgp dn42_${name}_v6 from dn42peers {\n";
        sessionBody = ''
    neighbor ${peer.neighborV6} % ${peer.networkInterface} as ${builtins.toString peer.neighborAS};
    direct;
        '';
        sessionEnd = "};\n";
        mpBgpPart = if peer.multiProtocolV6 then "" else ''
    ipv4 {
        import none;
        export none;
    };
        '';
    in sessionHead + sessionBody + mpBgpPart + sessionEnd;

    mkPeeringSession = name: peer: let
        v4Session = if peer.neighborV4 == null then "" else (mkV4Session name peer);
        v6Session = if peer.neighborV6 == null then "" else (mkV6Session name peer);
    in v4Session + v6Session;

    mkStaticSession = name: session: ''
protocol static static_${name}_v4 {
    route ${session.neighborV4} via ${session.networkInterface};
    route OWNNETv4 reject;

    ipv4 {
        import all;
        export none;
    };
}

protocol static static_${name}_v6 {
    route ${session.neighborV6} via ${session.networkInterface};
    route OWNNETv6 reject;

    ipv6 {
        import all;
        export none;
    };
}
    '';

    mkRpkiSession = name: rpkiServer: if !cfg.enableRoa then "" else ''
protocol rpki rpki_${name} {
    roa4 { table dn42_roa; };
    roa6 { table dn42_roa_v6; };
    remote ${rpkiServer.address} port ${builtins.toString rpkiServer.port};
    retry keep ${builtins.toString rpkiServer.retry};
    refresh keep ${builtins.toString rpkiServer.refresh};
    expire keep ${builtins.toString rpkiServer.expire};
};
    '';
    
in {
    options.services.dn42.bird2 = {
        enable = lib.mkEnableOption "Bird2 for DN42 networking";
        ownNetwork = lib.mkOption {
            type = types.ownNetwork;
            description = "Information of your own network.";
        };
        enableRoa = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Information of your own network.";
        };
        rpkiServers = lib.mkOption {
            type = lib.types.attrsOf types.rpkiServer;
            default = { };
            description = "Information of RPKI Server. Leave it as null to disable RPKI.";
        };
        staticSessions = lib.mkOption {
            type = lib.types.attrsOf types.staticSession;
            default = { };
            description = "Information of static sessions.";
        };
        peeringSessions = lib.mkOption {
            type = lib.types.attrsOf types.peeringSession;
            default = { };
            description = "Information of DN42 BGP peering sessions.";
        };
    };

    config = lib.mkIf cfg.enable (let
    in {
        boot.kernel.sysctl = {
            "net.ipv4.ip_forward" = 1;
            "net.ipv6.conf.default.forwarding" = 1;
            "net.ipv6.conf.all.forwarding" = 1;
            "net.ipv4.conf.default.rp_filter" = 0;
            "net.ipv4.conf.all.rp_filter" = 0;
            "net.ipv6.conf.default.rp_filter" = 0;
            "net.ipv6.conf.all.rp_filter" = 0;
        };

        services.bird = {
            enable = true;
            package = pkgs.bird2;
            config = let
                commonConfig = ''
define OWNIPv4     = ${cfg.ownNetwork.ipv4.ip};
define OWNNETv4    = ${cfg.ownNetwork.ipv4.cidr};
define OWNNETSETv4 = [ ${cfg.ownNetwork.ipv4.cidr}+ ];
define OWNIPv6     = ${cfg.ownNetwork.ipv6.ip};
define OWNNETv6    = ${cfg.ownNetwork.ipv6.cidr};
define OWNNETSETv6 = [ ${cfg.ownNetwork.ipv6.cidr}+ ];

router id OWNIPv4;

function is_self_net_v4() {
    return net ~ OWNNETSETv4;
}

function is_self_net_v6() {
    return net ~ OWNNETSETv6;
}

protocol device {
    scan time 10;
}

function is_valid_network() {
    return net ~ [
        172.20.0.0/14{21,29}, # dn42
        172.20.0.0/24{28,32}, # dn42 Anycast
        172.21.0.0/24{28,32}, # dn42 Anycast
        172.22.0.0/24{28,32}, # dn42 Anycast
        172.23.0.0/24{28,32}, # dn42 Anycast
        172.31.0.0/16+,       # ChaosVPN
        10.100.0.0/14+,       # ChaosVPN
        10.127.0.0/16{16,32}, # neonetwork
        10.0.0.0/8{15,24}     # Freifunk.net
    ];
}

function is_valid_network_v6() {
return net ~ [
    fd00::/8{44,64} # ULA address space as per RFC 4193
];
}

protocol kernel {
    scan time 20;

    ipv4 {
        import none;
        export filter {
            if source = RTS_STATIC then reject;
            krt_prefsrc = OWNIPv4;
            accept;
        };
    };
}

protocol kernel {
    scan time 20;

    ipv6 {
        import none;
        export filter {
            if source = RTS_STATIC then reject;
            krt_prefsrc = OWNIPv6;
            accept;
        };
    };
};
    '';

                roaConfig = if !cfg.enableRoa then "" else  ''
roa4 table dn42_roa;
roa6 table dn42_roa_v6;
protocol static {
    roa4 { table dn42_roa; };
    include "/etc/bird/dn42_roa.conf";
};

protocol static {
    roa6 { table dn42_roa_v6; };
    include "/etc/bird/dn42_roa_v6.conf";
};
    '';

                rpkiConfig = (lib.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs mkRpkiSession cfg.rpkiServers))) + "\n";
                templateRoaV4Config = if !cfg.enableRoa then "" else  ''
                if (roa_check(dn42_roa, net, bgp_path.last) != ROA_VALID) then {
                    print "[dn42] ROA check failed for ", net, " ASN ", bgp_path.last;
                    reject;
                }
                '';
                templateRoaV6Config = if !cfg.enableRoa then "" else  ''
                if (roa_check(dn42_roa_v6, net, bgp_path.last) != ROA_VALID) then {
                    print "[dn42] ROA check failed for ", net, " ASN ", bgp_path.last;
                    reject;
                }
                '';
                templateConfig = ''
template bgp dn42peers {
    local as OWNAS;
    path metric 1;
    ipv4 {
        import filter {
            if is_valid_network() && !is_self_net() then {
${templateRoaV4Config}
                accept;
            }
            reject;
        };

        export filter {
            if is_valid_network() && source ~ [RTS_STATIC, RTS_BGP] then accept;
            reject;
        };
        import limit 1000 action block;
        extended next hop yes;
    };
    ipv6 {
        import filter {
            if is_valid_network_v6() && !is_self_net_v6() then {
${templateRoaV6Config}
                accept;
            }
            reject;
        };
        export filter {
            if is_valid_network_v6() && source ~ [RTS_STATIC, RTS_BGP] then accept;
            reject;
        };
        import limit 1000 action block;
        extended next hop yes;
    };
}
                '';
                peeringConfig = (lib.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs mkPeeringSession cfg.peeringSessions))) + "\n";
                staticConfig = (lib.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs mkStaticSession cfg.staticSessions))) + "\n";
            in commonConfig + roaConfig + rpkiConfig + templateConfig + peeringConfig + staticConfig;
        };
        systemd.services.roaUpdate = lib.mkIf cfg.enableRoa {
            name = "roa-update";
            description = "Update ROA for dn42 Bird (IPv4)";
            wantedBy = [ "multi-user.target" ];
            before = [ "bird.service" ];
            serviceConfig = {
                Type = "oneshot";
                ExecStart = "wget -4 -O /tmp/dn42_roa.conf https://dn42.burble.com/roa/dn42_roa_bird2_4.conf";
                ExecStartPost = "ln -f /tmp/dn42_roa.conf /etc/bird/dn42_roa.conf";
            };
        };
        systemd.services.roaUpdateV6 = lib.mkIf cfg.enableRoa {
            name = "roa-update-v6";
            description = "Update ROA for dn42 Bird (IPv6)";
            wantedBy = [ "multi-user.target" ];
            before = [ "bird.service" ];
            serviceConfig = {
                Type = "oneshot";
                ExecStart = "wget -4 -O /tmp/dn42_roa_v6.conf https://dn42.burble.com/roa/dn42_roa_bird2_6.conf";
                ExecStartPost = "ln -f /tmp/dn42_roa_v6.conf /etc/bird/dn42_roa_v6.conf";
            };
        };
        environment.systemPackages = with pkgs; [
            wget
        ];
        services.cron.enable = true;
        services.cron.systemCronJobs = lib.mkIf cfg.enableRoa [
            "0 * * * * root wget -4 -O /tmp/dn42_roa.conf https://dn42.burble.com/roa/dn42_roa_bird2_4.conf && ln -f /tmp/dn42_roa.conf /etc/bird/dn42_roa.conf"
            "0 * * * * root wget -4 -O /tmp/dn42_roa_v6.conf https://dn42.burble.com/roa/dn42_roa_bird2_6.conf && ln -f /tmp/dn42_roa_v6.conf /etc/bird/dn42_roa_v6.conf"
            "0 * * * * root birdc configure"
        ];
    });
}