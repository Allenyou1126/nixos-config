{ config, lib, pkgs, modulesPath, ... }:

{
    imports = [
        ../../../modules/boot/efi-systemd.nix
        ../../../modules/common.nix
        ../../../modules/ssh.nix
        ../../../modules/dn42/coredns.nix
        ../../../modules/dn42/bird.nix
        ../../../modules/dn42/bird-lg-proxy.nix
        ../../../modules/dn42/wireguard.nix
        ./dn42/dns.nix
        ./dn42/bird.nix
        ./dn42/bird-lg-proxy.nix
        ./dn42/wireguard.nix
        ./hardware-configuration.nix
    ];
    environment.systemPackages = with pkgs; [
        vim
        wget
        git
    ];
    environment.variables.EDITOR = "vim";
}