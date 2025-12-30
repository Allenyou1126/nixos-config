{ config, lib, pkgs, ... }:

let
    cfg = config.services.dn42.coredns;
    types = rec {
        server = lib.types.submodule {
            options = {
                port = lib.mkOption {
                    type = lib.types.int;
                    default = 53;
                    description = "Port to run the DNS server on.";
                };
                zone = lib.mkOption {
                    type = lib.types.str;
                    description = "DNS zone to serve.";
                };
                plugins = lib.mkOption {
                    type = lib.types.listOf (lib.types.either lib.types.str (lib.types.listOf lib.types.str));
                    default = [ ];
                    description = "List of CoreDNS plugins to enable for this server block.";
                };
            };
            config = {
                assertions = [
                    {
                        assertion = cfg: (cfg.port >= 0 && cfg.port < 65536);
                        message = "The port must be between 0 and 65535.";
                    }
                    {
                        assertion = cfg: (lib.strings.hasSuffix "." cfg.zone);
                        message = "The DNS zone must end with a dot.";
                    }
                ];
            };
        };
        zoneFile = lib.types.submodule {
            options = {
                fileName = lib.mkOption {
                    type = lib.types.str;
                    description = "Name of the zone file. Can be accessed at /etc/coredns/zones/<fileName>.";
                };
                zone = lib.mkOption {
                    type = lib.types.str;
                    description = "DNS zone for this zone file.";
                };
                defaultTtl = lib.mkOption {
                    type = lib.types.int;
                    default = 300;
                    description = "Default TTL for records in this zone.";
                };
                records = lib.mkOption {
                    type = lib.types.listOf (lib.types.submodule {
                        options = {
                            name = lib.mkOption {
                                type = lib.types.str;
                                description = "Record name.";
                            };
                            class = lib.mkOption {
                                type = lib.types.str;
                                default = "IN";
                                description = "Record class.";
                            };
                            type = lib.mkOption {
                                type = lib.types.str;
                                description = "Record type (e.g., A, AAAA, CNAME).";
                            };
                            value = lib.mkOption {
                                type = lib.types.str;
                                description = "Record value.";
                            };
                            ttl = lib.mkOption {
                                type = lib.types.int;
                                default = 300;
                                description = "Time to live for the record.";
                            };
                        };
                    });
                    default = [ ];
                    description = "List of DNS records to serve in this zone. Leave empty to disable static records.";
                };
                soa = lib.mkOption {
                    type = lib.types.nullOr (lib.types.submodule {
                        options = {
                            mname = lib.mkOption {
                                type = lib.types.str;
                                description = "Primary master name server for the zone.";
                            };
                            rname = lib.mkOption {
                                type = lib.types.str;
                                description = "Responsible party for the zone.";
                            };
                            serial = lib.mkOption {
                                type = lib.types.int;
                                default = 0;
                                description = "Serial number for the zone.";
                            };
                            refresh = lib.mkOption {
                                type = lib.types.int;
                                default = 28800;
                                description = "Refresh interval for the zone.";
                            };
                            retry = lib.mkOption {
                                type = lib.types.int;
                                default = 7200;
                                description = "Retry interval for the zone.";
                            };
                            expire = lib.mkOption {
                                type = lib.types.int;
                                default = 604800;
                                description = "Expire time for the zone.";
                            };
                            minimum = lib.mkOption {
                                type = lib.types.int;
                                default = 60;
                                description = "Minimum TTL for the zone.";
                            };
                        };
                    });
                    default = null;
                    description = "SOA record configuration for the zone.";
                };
            };
            config = {
                assertions = [
                    {
                        assertion = cfg: (builtins.length cfg.records == 0 ||
                                        lib.all (record: lib.elem record.type [ "A" "AAAA" "CNAME" "TXT" "MX" "NS" "SRV" "PTR" ]) cfg.records);
                        message = "All record types must be one of A, AAAA, CNAME, TXT, MX, NS, PTR, or SRV.";
                    }
                    {
                        assertion = cfg: (builtins.length cfg.records == 0 || 
                                    (cfg.soa != null && 
                                     lib.all (record: record.ttl > cfg.soa.minimum) cfg.records));
                        message = "All record TTL should be never below the minimum in SOA record.";
                    }
                ];
            };
        };
    };
    mkRecord = record: "${record.name} ${toString record.ttl} ${record.class} ${record.type} ${record.value}\n";
    mkSoaRecord = soa: "@ IN SOA ${soa.mname} ${soa.rname} ${toString soa.serial} ${toString soa.refresh} ${toString soa.retry} ${toString soa.expire} ${toString soa.minimum}\n";
    mkZoneFile = zone: let
        originText = "$ORIGIN ${zone.zone}\n";
        ttlText = "$TTL ${toString zone.defaultTtl}\n";
        recordsText = lib.concatMap mkRecord zone.records;
        soaText = if zone.soa != null then mkSoaRecord zone.soa else "";
    in {
        "coredns/zones/${zone.fileName}" = {
            text = originText + ttlText + soaText + recordsText;
        };
    };
    mkCoreDnsConfig = serverBlocks: let
        renderServerBlock = server:
            "${server.zone}:${toString server.port} {\n" +
            (if lib.length server.plugins > 0
            then
                (lib.concatMap (plugin: ("    " + (if lib.isList plugin then lib.concatStringsSep " " plugin else plugin))) server.plugins) + "\n"
            else "") +
            "}\n";
    in lib.concatMap renderServerBlock serverBlocks;
in {
    options.services.dn42.coredns = {
        enable = lib.mkEnableOption "CoreDNS for DN42 networking";

        serverBlocks = lib.mkOption {
            type = lib.types.listOf types.server;
            default = [ ];
            description = "List of DNS zones to serve for DN42.";
        };

        zoneFiles = lib.mkOption {
            type = lib.types.listOf types.zoneFile;
            default = [ ];
            description = "List of zone files to create for CoreDNS.";
        };

        extraCommandLineOptions = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Extra command line options to pass to the CoreDNS server.";
        };
    };

    config = lib.mkIf cfg.enable (let
        zoneFiles = builtins.foldl' (x: y: x // y) {} (map mkZoneFile cfg.zoneFiles);
        config = mkCoreDnsConfig cfg.serverBlocks;
    in {
        services.coredns = {
            enable = true;
            package = pkgs.coredns;
            extraArgs = cfg.extraCommandLineOptions;
        };

        environment.etc = zoneFiles;

        services.coredns.config = config;
    });
}