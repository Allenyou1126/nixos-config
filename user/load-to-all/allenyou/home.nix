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
            export PATH="$PATH:$HOME/bin:$HOME/.local/bin"
        '';
    };
}