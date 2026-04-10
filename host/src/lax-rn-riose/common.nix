{
  pkgs,
  ...
}:

{
  imports = [
    ../../../modules/boot/bios-grub.nix
    ../../../modules/common.nix
    ../../../modules/ssh.nix
    ../../../modules/dn42/coredns.nix
    ../../../modules/dn42/bird.nix
    ../../../modules/dn42/bird-lg-proxy.nix
    ../../../modules/dn42/wireguard.nix
    ./dn42/dns.nix
    ./dn42/bird.nix
    ./dn42/bird-lg-proxy.nix
    ./dn42/wireguard.nix
    ./hardware-configuration.nix
    ./exporters.nix
  ];
  system.allenyou.motd.description = "DN42 server";
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];
  networking.nameservers = [
    "172.23.0.53"
    "8.8.8.8"
  ];
  services.resolved = {
    enable = true;
    fallbackDns = [
      "1.1.1.1"
    ];
  };
  environment.variables.EDITOR = "vim";
  system.stateVersion = "25.11";
}
