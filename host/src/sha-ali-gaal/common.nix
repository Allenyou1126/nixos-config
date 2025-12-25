{ config, lib, pkgs, modulesPath, ... }:

{
    imports = [
        ../../../modules/boot/efi-systemd.nix
        ../../../modules/nix-store-mirror.nix
        ../../../modules/common.nix
        ../../../modules/ssh.nix
        ./hardware-configuration.nix
    ];
    environment.systemPackages = with pkgs; [
        vim
        wget
        git
    ];
    environment.variables.EDITOR = "vim";
}