{ config, lib, pkgs, ... }:

let
    cfg = config.services.dn42.wireguard;
    types = rec {
        networkConfig = lib.types.submodule {
            options = {
                addressV4 = lib.mkOption {
                    type = lib.types.str;
                    description = "The IPv4 address of this server.";
                };
                addressV6 = lib.mkOption {
                    type = lib.types.str;
                    description = "The IPv6 address of this server.";
                };
                localLinkAddressV6 = lib.mkOption {
                    type = lib.types.str;
                    description = "The Local Link IPv6 address of this server.";
                };
                privateKeyFile = lib.mkOption {
                    type = lib.types.path;
                    description = "The path to the private key file.";
                };  
            };
        };
        peeringSession = lib.types.submodule {
            options = {
                addressV4 = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                    description = "The IPv4 address of your neighbor to create Session to. Leave it as null will disable IPv4 Session.";
                };
                addressV6 = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                    description = "The IPv6 address of your neighbor to create Session to. Leave it as null will disable IPv6 Session.";
                };
                localLinkAddressV6 = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                    description = "The Local Link IPv6 address of your neighbor to create Session to. Leave it as null will disable IPv6 Session.";
                };
                endpoint = lib.mkOption {
                    type = lib.types.str;
                    description = "The endpoint of your neighbor to create Session to.";
                };
                publicKey = lib.mkOption {
                    type = lib.types.str;
                    description = "The base64 encoded public key of your neighbor to create Session to.";
                };
                listenPort = lib.mkOption {
                    type = lib.types.port;
                    description = "The port to listen on.";
                };
            };
        };
        staticSession = lib.types.submodule {
            options = {
                addressV4 = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                    description = "The IPv4 address of your neighbor to create Session to. Leave it as null will disable IPv4 Session.";
                };
                addressV6 = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                    description = "The IPv6 address of your neighbor to create Session to. Leave it as null will disable IPv6 Session.";
                };
                isGateway = lib.mkOption {
                    type = lib.types.bool;
                    default = false;
                    description = "Whether your neighbor is a gateway.";
                };
                endpoint = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                    description = "The endpoint of your neighbor to create Session to. Leave it as null to just wait your neighbor to connect yourself.";
                };
                publicKey = lib.mkOption {
                    type = lib.types.str;
                    description = "The base64 encoded public key of your neighbor to create Session to.";
                };
                listenPort = lib.mkOption {
                    type = lib.types.nullOr lib.types.port;
                    default = null;
                    description = "The port to listen on. Leave it as null to only connect to your neighbor.";
                };
            };
        };
    };

    commonConfig = {
        autostart = true;
        table = "off";
    };

    mkDn42PeeringSession = name: config: let
        initV4 = if config.addressV4 == null then "" else "ip addr add ${cfg.local.addressV4} peer ${config.addressV4} dev %i";
        initV6 = if config.addressV6 == null then "" else "ip addr add ${cfg.local.addressV6} peer ${config.addressV6} dev %i";
        initLocalLinkV6 = if config.localLinkAddressV6 == null then "" else "ip addr add ${cfg.local.localLinkAddressV6} peer ${config.localLinkAddressV6} dev %i";
    in {
        name = "dn42-${name}";
        value = commonConfig // {
            listenPort = config.listenPort;
            privateKeyFile = cfg.local.privateKeyFile;
            postUp = ''
                ${initV4}
                ${initV6}
                ${initLocalLinkV6}
                sysctl -w net.ipv6.conf.%i.autoconf=0
            '';
            peers = [
                {
                    endpoint = config.endpoint;
                    publicKey = config.publicKey;
                    allowedIPs = [
                        "10.0.0.0/8"
                        "172.20.0.0/14"
                        "172.31.0.0/16"
                        "fd00::/8"
                        "fe80::/64"
                    ];
                }
            ];
        };
    };
    
    mkGatewaySession = name: config: {
        postUp = ''
            sysctl -w net.ipv6.conf.%i.autoconf=0
            ip addr add ${cfg.local.addressV4} dev %i
            ip addr add ${cfg.local.addressV6} dev %i
        '';
    };

    mkNonGatewaySession = name: config: {
        postUp = ''
            sysctl -w net.ipv6.conf.%i.autoconf=0
            ip addr add ${cfg.local.addressV4} dev %i
            ip addr add ${cfg.local.addressV6} dev %i
            ip route add 172.20.0.0/14 via ${config.addressV4} dev %i
            ip route add 172.31.0.0/16 via ${config.addressV4} dev %i
            ip route add fd00::/8 via ${config.addressV6} dev %i
        '';
        
    };

    mkStaticSession = name: config: {
        name = name;
        value = commonConfig // ((if config.isGateway then mkGatewaySession else mkNonGatewaySession) name config) // {
            listenPort = config.listenPort;
            privateKeyFile = cfg.local.privateKeyFile;
            peers = [
                {
                    endpoint = config.endpoint;
                    publicKey = config.publicKey;
                    allowedIPs = [
                        "10.0.0.0/8"
                        "172.20.0.0/14"
                        "172.31.0.0/16"
                        "fd00::/8"
                        "fe80::/64"
                    ];
                }
            ];
        };
    };

in {
    options.services.dn42.wireguard = {
        enable = lib.mkEnableOption "Wireguard for DN42 networking";
        local = lib.mkOption {
            type = types.networkConfig;
            description = "Information of your local network.";
        };
        dn42PeeringSessions = lib.mkOption {
            type = lib.types.attrsOf types.peeringSession;
            default = { };
            description = "Information of DN42 peering sessions.";
        };
        staticSessions = lib.mkOption {
            type = lib.types.attrsOf types.staticSession;
            default = { };
            description = "Information of static sessions.";
        };
    };

    config = lib.mkIf cfg.enable (let
        dn42PeeringSessions = builtins.mapAttrs mkDn42PeeringSession cfg.dn42PeeringSessions;
        staticSessions = builtins.mapAttrs mkStaticSession cfg.staticSessions;
    in ({
        networking.wg-quick.interfaces = builtins.listToAttrs (
            builtins.attrValues dn42PeeringSessions ++
            builtins.attrValues staticSessions
        );
    }));
}