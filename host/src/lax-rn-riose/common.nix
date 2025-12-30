{ config, lib, pkgs, modulesPath, ... }:

{
    imports = [
        ../../../modules/boot/efi-systemd.nix
        ../../../modules/common.nix
        ../../../modules/ssh.nix
        ../../../modules/dn42/coredns.nix
        ./dn42/dns.nix
        ./hardware-configuration.nix
    ];
    environment.systemPackages = with pkgs; [
        vim
        wget
        git
    ];
    environment.variables.EDITOR = "vim";
}