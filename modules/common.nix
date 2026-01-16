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
  i18n.defaultLocale = "en_US.UTF-8";
}
