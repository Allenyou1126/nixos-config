{ pkgs, ... }:

## Application server
# App:

{
  imports = [
    ../../../modules/boot/bios-grub.nix
    ../../../modules/common.nix
    ../../../modules/ssh.nix
    ../../../modules/wakapi.nix
    ./hardware-configuration.nix
    ./nginx.nix
    ./postgres.nix
    ./wireguard.nix
    ./waline.nix
    ./waline-zlight106.nix
    ./certimate.nix
    ./webdav.nix
    ./bird-lg.nix
    ./miniflux.nix
    ./vaultwarden.nix
    ./wakapi.nix
    ./lotusland.nix
    ./blog.nix
    ./zlight106-blog.nix
    ./umami.nix
    ./exporters.nix
  ];
  system.allenyou.motd.description = "Application server.";
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];
  environment.variables.EDITOR = "vim";
  system.stateVersion = "25.11";
}
