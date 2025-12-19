{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "nixos-server";

  time.timeZone = "Asia/Shanghai";
  nix.settings.experimental-features = ["nix-command" "flakes"];

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.allenyou = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFhiR8t5soqwfpcemRLTe9StCSGsD36TyJgE9PGcjJk cfan7@Allenyou-Laptop"
    ];
  };

  environment.systemPackages = with pkgs; [
    vim 
    wget
    git
  ];
  environment.variables.EDITOR = "vim";

  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };


  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no"; # disable root login
      PasswordAuthentication = false; # disable password login
    };
    ports = [ 2333 ];
    openFirewall = true;
  };

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  nix.settings.substituters = [
    "https://mirrors.ustc.edu.cn/nix-channels/store"
  ];
  system.stateVersion = "25.05"; # Did you read the comment?

}

