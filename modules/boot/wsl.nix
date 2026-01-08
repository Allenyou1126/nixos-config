{ config, pkgs, lib, input }:

let
    nixos-wsl = input.nixos-wsl;
in {
    imports = [
        nixos-wsl.nixosModules.wsl
    ];

    wsl = {
        enable = true;
        defaultUser = "allenyou";
        startMenuLaunchers = false;
    };
}