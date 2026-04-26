{
  pkgs,
  ...
}:

{
  imports = [
    ../../../modules/nix-store-mirror.nix
    ../../../modules/common.nix
  ];
  system.allenyou.motd.description = "Development Laptop";
  programs.ssh.startAgent = true;
  programs.nix-ld.enable = true;
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];
  environment.variables.EDITOR = "vim";
  system.stateVersion = "25.11";
}
