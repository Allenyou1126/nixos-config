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
    ./exporters.nix
    ./nginx.nix
    ./postgres.nix
    ./wireguard.nix
    ./apps/waline.nix
    ./apps/waline-zlight106.nix
    ./apps/certimate.nix
    ./apps/webdav.nix
    ./apps/bird-lg.nix
    ./apps/miniflux.nix
    ./apps/vaultwarden.nix
    ./apps/wakapi.nix
    ./apps/lotusland.nix
    ./apps/blog.nix
    ./apps/zlight106-blog.nix
    ./apps/umami.nix
    ./apps/openwebui.nix
  ];
  system.allenyou.motd.description = "Application server.";
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];
  networking.nameservers = [
    "172.20.0.53"
    "8.8.8.8"
  ];
  services.resolved = {
    enable = true;
    fallbackDns = [
      "1.1.1.1"
      "172.23.0.53"
    ];
  };
  environment.variables.EDITOR = "vim";
  system.stateVersion = "25.11";
}
