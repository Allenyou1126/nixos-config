{ pkgs, ... }:

{
  imports = [
    ../../../modules/boot/efi-systemd.nix
    ../../../modules/nix-store-mirror.nix
    ../../../modules/common.nix
    ../../../modules/ssh.nix
    ./hardware-configuration.nix
    # ./postgres.nix
    # ./zitadel.nix
  ];
  system.allenyou.motd.description = "Test server";
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];
  environment.variables.EDITOR = "vim";
  system.stateVersion = "25.05";
}
