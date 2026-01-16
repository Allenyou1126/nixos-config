{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nixfmt-rfc-style
    nil
  ];
  home.sessionVariables = {
    GPG_TTY = "$(tty)";
  };
}
