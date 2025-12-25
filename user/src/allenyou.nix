{ config, pkgs, ... }:

{
    common = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPassword = "$6$LUaEhWcWLrsJap7N$OiTNNYisJvE8kKwXlgw8gwixmmWQqbVHiXtNnaF9nHw/UegFSz22ofr5NDiQwuGKCQXTRTUTew1owOZpY2hxk0";
        openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFhiR8t5soqwfpcemRLTe9StCSGsD36TyJgE9PGcjJk allenyou@lap-fallom"
        ];
    };
    home = {
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
                export PATH="$PATH:$HOME/bin:$HOME/.local/bin"
            '';
        };
        home.stateVersion = "25.05";
    };
}