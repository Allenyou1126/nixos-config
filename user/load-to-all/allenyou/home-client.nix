{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nixfmt-rfc-style
    nil
  ];
  home.sessionVariables = {
    GPG_TTY = "$(tty)";
  };
  programs.git = {
    settings = {
      user.signingkey = "i@allenyou.wang";
      http.sslverify = false;
      commit.gpgsign = true;
      core.editor = "vim";
    };
  };
  programs.ssh.matchBlocks = {
    home-ebeling = {
      hostname = "192.168.100.60";
      user = "allenyou";
      identityFile = "~/.ssh/id_ed25519";
    };
    "github.com" = {
      hostname = "ssh.github.com";
      port = 443;
      user = "git";
      identityFile = "~/.ssh/id_ed25519";
    };
    "git.dn42.dev" = {
      hostname = "git.dn42.dev";
      port = 22;
      user = "git";
      identityFile = "~/.ssh/id_ed25519";
    };
    lax-rn-riose = {
      proxyJump = "hkg-dog-darell";
    };
  };
}
