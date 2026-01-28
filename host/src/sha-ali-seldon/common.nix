{ pkgs, ... }:

{
  imports = [
    ../../../modules/boot/efi-systemd.nix
    ../../../modules/nix-store-mirror.nix
    ../../../modules/common.nix
    ../../../modules/ssh.nix
    ./hardware-configuration.nix
    ./wireguard.nix
    ./frps.nix
    ./nginx.nix
    ./exporters.nix
  ];
  boot.loader.efi.efiSysMountPoint = "/efi";
  system.allenyou.motd.description = "Network gateway server.";
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];
  environment.variables.EDITOR = "vim";
  system.stateVersion = "25.11";
}
