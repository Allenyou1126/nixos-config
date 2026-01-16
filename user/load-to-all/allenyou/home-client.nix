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
}
