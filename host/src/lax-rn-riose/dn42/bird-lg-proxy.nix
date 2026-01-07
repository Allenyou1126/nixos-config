{ config, lib, pkgs, modulesPath, ... }:

let
in {
    services.dn42.bird-lg-proxy = {
        enable = true;
        address = "172.21.89.225";
    };
}