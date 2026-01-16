{ ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
    ports = [ 2333 ];
    openFirewall = true;
  };

  programs.ssh.startAgent = true;
}
