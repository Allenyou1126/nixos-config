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
    sftpServerExecutable = "internal-sftp";
  };

  programs.ssh.startAgent = true;
}
