{ pkgs, ... }:

{
  imports = [
    ../../../modules/boot/efi-systemd.nix
    ../../../modules/nix-store-mirror.nix
    ../../../modules/common.nix
    ../../../modules/ssh.nix
    ./deepseek-harness.nix
    ./hardware-configuration.nix
    ./exporters.nix
  ];
  system.allenyou.motd.description = "Homelab server";
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];
  environment.variables.EDITOR = "vim";
  system.stateVersion = "25.11";
}
