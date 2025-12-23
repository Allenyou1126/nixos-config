{ pkgs, ... }:

{
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
        tree
    ];
    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFhiR8t5soqwfpcemRLTe9StCSGsD36TyJgE9PGcjJk cfan7@Allenyou-Laptop"
    ];
}