{ config, lib, pkgs, modulesPath, ... }:

let
in {
    services.dn42.bird2 = {
        enable = true;
        ownNetwork = {
            asn = 4242421056;
            ipv4 = {
                ip = "";
                cidr = "";
            };
            ipv6 = {
                ip = "";
                cidr = "";
            };
        };
        rpkiServers = {
            akix = {
                address = "";
                port = 8282;
            };
        };
        staticSessions = {

        };
        peeringSessions = {
            test = {
                neighborAS = 4242421234;
                networkInterface = "test";
                neighborV4 = "";
                neighborV6 = "";
            };
        };
    }
}