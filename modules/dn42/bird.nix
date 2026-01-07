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
            neighbor ${peer.neighborV4} % '${peer.networkInterface}' as ${builtins.toString peer.neighborAS};
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
            neighbor ${peer.neighborV6} % '${peer.networkInterface}' as ${builtins.toString peer.neighborAS};
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
        protocolName = builtins.replaceStrings [ "-" ] [ "_" ] name;
        v4Session = if peer.neighborV4 == null then "" else (mkV4Session protocolName peer);
        v6Session = if peer.neighborV6 == null then "" else (mkV6Session protocolName peer);
    in v4Session + v6Session;

    mkStaticSession = name: session: let
        protocolName = builtins.replaceStrings [ "-" ] [ "_" ] name;
    in ''
        protocol static static_${protocolName}_v4 {
            route ${session.neighborV4} via "${session.networkInterface}";
            route OWNNETv4 reject;

            ipv4 {
                import all;
                export none;
            };
        }

        protocol static static_${protocolName}_v6 {
            route ${session.neighborV6} via "${session.networkInterface}";
            route OWNNETv6 reject;

            ipv6 {
                import all;
                export none;
            };
        }
    '';

    mkRpkiSession = name: rpkiServer: if !cfg.enableRoa then "" else ''
        protocol rpki rpki_${name} {
            roa4 { table dn42_roa_v4_table; };
            roa6 { table dn42_roa_v6_table; };
            remote "${rpkiServer.address}" port ${builtins.toString rpkiServer.port};
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
            preCheckConfig = ''
                touch /tmp/dn42_roa_v4.conf
                touch /tmp/dn42_roa_v6.conf
            '';
            config = let
                commonConfig = ''
                    define OWNAS       = ${builtins.toString cfg.ownNetwork.asn};
                    define OWNIPv4     = ${cfg.ownNetwork.ipv4.ip};
                    define OWNNETv4    = ${cfg.ownNetwork.ipv4.cidr};
                    define OWNNETSETv4 = [ ${cfg.ownNetwork.ipv4.cidr}+ ];
                    define OWNIPv6     = ${cfg.ownNetwork.ipv6.ip};
                    define OWNNETv6    = ${cfg.ownNetwork.ipv6.cidr};
                    define OWNNETSETv6 = [ ${cfg.ownNetwork.ipv6.cidr}+ ];

                    router id OWNIPv4;

                    function is_self_net_v4() -> bool {
                        return net ~ OWNNETSETv4;
                    }

                    function is_self_net_v6() -> bool {
                        return net ~ OWNNETSETv6;
                    }

                    protocol device {
                        scan time 10;
                    }

                    function is_valid_network_v4() -> bool {
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

                    function is_valid_network_v6() -> bool {
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
                    roa4 table dn42_roa_v4_table;
                    roa6 table dn42_roa_v6_table;
                    protocol static dn42_roa_v4 {
                        roa4 { table dn42_roa_v4_table; };
                        include "/tmp/dn42_roa_v4.conf";
                    };

                    protocol static dn42_roa_v6 {
                        roa6 { table dn42_roa_v6_table; };
                        include "/tmp/dn42_roa_v6.conf";
                    };
                '';

                rpkiConfig = (lib.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs mkRpkiSession cfg.rpkiServers))) + "\n";
                templateRoaV4Config = if !cfg.enableRoa then "" else  ''
                    if (roa_check(dn42_roa_v4_table, net, bgp_path.last) != ROA_VALID) then {
                        print "[dn42] ROA check failed for ", net, " ASN ", bgp_path.last;
                        reject;
                    }
                '';
                templateRoaV6Config = if !cfg.enableRoa then "" else  ''
                    if (roa_check(dn42_roa_v6_table, net, bgp_path.last) != ROA_VALID) then {
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
                                if is_valid_network_v4() && !is_self_net_v4() then {
                                    ${templateRoaV4Config}
                                    accept;
                                }
                                reject;
                            };

                            export filter {
                                if is_valid_network_v4() && source ~ [RTS_STATIC, RTS_BGP] then accept;
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
        users = {
            users.bird = {
                description = "BIRD Internet Routing Daemon user";
                group = "bird";
                isSystemUser = true;
            };
            groups.bird = { };
        };
        systemd.services.bird.serviceConfig = lib.mkForce {
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            NoNewPrivileges = true;
            PrivateMounts = true;
            PrivateTmp = true;
            ProcSubset = "pid";
            ProtectHome = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectProc = "invisible";
            ProtectSystem = "strict";
            RemoveIPC = true;
            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            SystemCallArchitectures = "native";
            SystemCallErrorNumber = "EPERM";
            PrivateDevices = false;
            ProtectClock = false;
            ProtectControlGroups = false;
            AmbientCapabilities = [
                "CAP_NET_ADMIN"
                "CAP_NET_BIND_SERVICE"
                "CAP_NET_RAW"
            ];
            CapabilityBoundingSet = [
                "CAP_NET_ADMIN"
                "CAP_NET_BIND_SERVICE"
                "CAP_NET_RAW"
            ];
            RestrictAddressFamilies = [
                "AF_UNIX"
                "AF_INET"
                "AF_INET6"
                "AF_NETLINK"
            ];
            SystemCallFilter = [ ];
            ExecPostStart = "${pkgs.wget}/bin/wget -4 -O /tmp/dn42_roa_v4.conf https://dn42.burble.com/roa/dn42_roa_bird2_4.conf && ${pkgs.wget}/bin/wget -4 -O /tmp/dn42_roa_v6.conf https://dn42.burble.com/roa/dn42_roa_bird2_6.conf";
            ExecStart = "${lib.getExe' pkgs.bird2 "bird"} -f -c /etc/bird/bird.conf";
            ExecReload = "${lib.getExe' pkgs.bird2 "birdc"} configure";

            CPUQuota = "10%";
            Restart = lib.mkForce "always";

            User = "bird";
            Group = "bird";
            RuntimeDirectory = "bird";
        };
        environment.systemPackages = with pkgs; [
            wget
        ];
        services.cron.enable = true;
        services.cron.systemCronJobs = lib.mkIf cfg.enableRoa [
            "0 * * * * root wget -4 -O /tmp/dn42_roa_v4.conf https://dn42.burble.com/roa/dn42_roa_bird2_4.conf"
            "0 * * * * root wget -4 -O /tmp/dn42_roa_v6.conf https://dn42.burble.com/roa/dn42_roa_bird2_6.conf"
            "0 * * * * root birdc configure"
        ];
    });
}