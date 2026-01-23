{ pkgs, ... }:

{
  home.packages = with pkgs; [
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

    just
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "Allen You";
      user.email = "i@allenyou.wang";
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin"
    '';
  };

  programs.ssh.matchBlocks = {
    hkg-dog-darell = {
      hostname = "hkg-dog-darell.server.allenyou.wang";
      port = 2333;
      tcpKeepAlive = true;
      user = "allenyou";
      identityFile = "~/.ssh/id_ed25519";
    };
    sha-ali-seldon = {
      hostname = "sha-ali-seldon.server.allenyou.wang";
      port = 2333;
      tcpKeepAlive = true;
      user = "allenyou";
      identityFile = "~/.ssh/id_ed25519";
    };
    sha-ali-gaal = {
      hostname = "sha-ali-gaal.server.allenyou.wang";
      port = 2333;
      tcpKeepAlive = true;
      user = "allenyou";
      identityFile = "~/.ssh/id_ed25519";
    };
    lax-rn-riose = {
      hostname = "lax-rn-riose.server.allenyou.wang";
      port = 2333;
      tcpKeepAlive = true;
      user = "allenyou";
      identityFile = "~/.ssh/id_ed25519";
    };
  };

  home.stateVersion = "25.11";
}
