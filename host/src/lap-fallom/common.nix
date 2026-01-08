{ config, lib, pkgs, modulesPath, ... }:

{
    imports = [
        ../../../modules/boot/wsl.nix
        ../../../modules/nix-store-mirror.nix
        ../../../modules/common.nix
    ];
    programs.ssh.startAgent = true;
    environment.systemPackages = with pkgs; [
        vim
        wget
        git
    ];
    environment.variables.EDITOR = "vim";
    system.stateVersion = "25.05";
}