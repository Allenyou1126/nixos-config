{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nixfmt-rfc-style
    nil
  ];
  environment.variables = {
    GPG_TTY = "$(tty)";
  };
}
