{ config, lib, pkgs, modulesPath, ... }:

let
    serial = 2025123100;
in {
    services.dn42.coredns = {
        enable = true;
        zoneFiles = [
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
                ];
            }
        ];
        serverBlocks = [
            {
                zone = "allenyou.dn42";
                plugins = [
                    "log"
                    [ "file" "/etc/coredns/zones/allenyou.dn42.zone" ]
                ];
            }
        ];
    };
}