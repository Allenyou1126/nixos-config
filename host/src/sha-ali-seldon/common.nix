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
  ];
  boot.loader.efi.efiSysMountPoint = "/efi";
  system.allenyou.motd.description = "Network gateway server.";
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];
  # users.allenyou.openssh.authorizedKeys.keys = [
  #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBq9keAjGoyEdP3RMBymnNTrWjg9j1vlcxe+jGrMUov+ allenyou@Certimate"
  # ];
  environment.variables.EDITOR = "vim";
  system.stateVersion = "25.11";
}
