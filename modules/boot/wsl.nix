{ config, pkgs, lib, inputs }:

let
    nixos-wsl = inputs.nixos-wsl;
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