{ pkgs, ... }:

## Application server
# App:

{
  imports = [
    ../../../modules/boot/bios-grub.nix
    ../../../modules/nix-store-mirror.nix
    ../../../modules/common.nix
    ../../../modules/ssh.nix
    ../../../modules/wakapi.nix
    ./hardware-configuration.nix
    ./nginx.nix
    ./postgres.nix
    ./wireguard.nix
    # # Waline
    # ./waline.nix
    # # Waline for zlight106
    # ./waline-zlight106.nix
    # # Certimate
    # ./certimate.nix
    # # WebDAV
    # ./webdav.nix
    # # Bird-lg
    # ./bird-lg.nix
    # # Miniflux
    # ./miniflux.nix
    # # Vaultwarden
    # ./vaultwarden.nix
    # # Wakapi
    # ./wakapi.nix
    # # Lotusland
    # ./lotusland.nix
    # # Blog
    # ./blog.nix
    # # Blog for zlight106
    # ./zlight106-blog.nix
    # # Umami
    # ./umami.nix
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
