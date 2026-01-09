{ ... }:

{
  imports = [
    ./motd.nix
  ];
  system.allenyou.motd.enable = true;
  time.timeZone = "Asia/Shanghai";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  i18n.defaultLocale = "en_US.UTF-8";
}
