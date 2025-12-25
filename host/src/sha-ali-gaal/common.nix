{ config, lib, pkgs, modulesPath, ... }:

{
    imports = [
        ../../../boot/efi-systemd.nix
        ../../../nix-store-mirror.nix
        ../../../ssh.nix
        ./hardware-configuration.nix
    ];
    environment.systemPackages = with pkgs; [
        vim
        wget
        git
    ];
    environment.variables.EDITOR = "vim";
}