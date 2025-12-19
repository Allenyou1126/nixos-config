{ config, pkgs, ... }:

{
  home.username = "allenyou";
  home.homeDirectory = "/home/allenyou";

  home.packages = with pkgs;[
    zip
    xz
    unzip
    p7zip

    mtr
    iperf3
    dnsutils
    socat
    nmap

    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg

    nix-output-monitor

    htop
    strace
    ltrace
    lsof

    sysstat
    ethtool
  ];

  programs.git = {
    enable = true;
    settings.user.name = "Allen You";
    settings.user.email = "i@allenyou.wang";
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";
}
