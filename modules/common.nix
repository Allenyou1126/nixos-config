{ ... }:

{
  imports = [
    ./motd.nix
  ];
  system.allenyou.motd = {
    enable = true;
    banner = ''
      _   _                       _   _      _   
      | \ | |                     | \ | |    | |  
      |  \| | _____  ___   _ ___  |  \| | ___| |_ 
      | . ` |/ _ \ \/ / | | / __| | . ` |/ _ \ __|
      | |\  |  __/>  <| |_| \__ \ | |\  |  __/ |_ 
      |_| \_|\___/_/\_\\__,_|___/ |_| \_|\___|\__|                   
    '';
  };
  time.timeZone = "Asia/Shanghai";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "allenyou"
  ];
  networking.nameservers = [
    "8.8.8.8"
    "4.4.4.4"
    "1.1.1.1"
    "172.21.89.225"
    "172.20.0.53"
    "172.23.0.53"
  ];
  i18n.defaultLocale = "en_US.UTF-8";
}
