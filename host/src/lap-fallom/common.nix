{
  pkgs,
  inputs,
  ...
}:

let
  nixos-wsl = inputs.nixos-wsl;
in
{
  imports = [
    nixos-wsl.nixosModules.wsl
    ../../../modules/nix-store-mirror.nix
    ../../../modules/common.nix
  ];
  wsl = {
    enable = true;
    defaultUser = "allenyou";
  };
  system.allenyou.motd.description = "Client Laptop running in WSL.";
  security.sudo.wheelNeedsPassword = true;
  programs.ssh.startAgent = true;
  programs.nix-ld.enable = true;
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];
  environment.variables.EDITOR = "vim";
  system.stateVersion = "25.05";
  home-manager.users.allenyou.home.shellAliases = {
    gpg = "/mnt/c/Program\\ Files/Git/usr/bin/gpg.exe";
  };
  home-manager.users.allenyou.programs.git.settings.gpg.program =
    "/mnt/c/Program Files/Git/usr/bin/gpg.exe";
  security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
      MIID3DCCAsSgAwIBAgIIJaH6JZy5Y24wDQYJKoZIhvcNAQELBQAwZzEfMB0GA1UEAxMWU3RlYW1U
      b29scyBDZXJ0aWZpY2F0ZTEdMBsGA1UECxMUVGVjaG5pY2FsIERlcGFydG1lbnQxGDAWBgNVBAoT
      D0JleW9uZERpbWVuc2lvbjELMAkGA1UEBhMCQ04wHhcNMjUxMDE5MTYwMDAwWhcNMjYwODE2MTYw
      MDAwWjBnMR8wHQYDVQQDExZTdGVhbVRvb2xzIENlcnRpZmljYXRlMR0wGwYDVQQLExRUZWNobmlj
      YWwgRGVwYXJ0bWVudDEYMBYGA1UEChMPQmV5b25kRGltZW5zaW9uMQswCQYDVQQGEwJDTjCCASIw
      DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANB80OAoBOh9V9f6LrzwhOSnljyot9uMr7AiSCM+
      3QNynkFNxIHOZYGi4Z3J+f6NmOjTihmhi2PLktdFVniJUhcOuEq4yECXaZ+YkPdgc7rJKfula/vf
      K2cFd//Z3nojgTKUkvLFzsv9t5yRr7BK2RFdfNX76ZVDtA5fmVb3GJGo3DpDJpg04Dw+JATqpivj
      2LzjZJs31prWyQhTCJC2TpNFVdxfW4Wk7ITBHsLg9r/Brgum9H4fAst9jlaAvm14dF134mZlDFj3
      Fq12j8AXnEzy/LaZhQHCpeKaqYBmCJix5jfx9qxpK//i/hmIknG1razXDBmqUrxxNWmA0hkW1e0C
      AwEAAaOBizCBiDASBgNVHRMBAf8ECDAGAQH/AgEBMA4GA1UdDwEB/wQEAwIBhjAgBgNVHSUBAf8E
      FjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwIQYDVR0RBBowGIIWU3RlYW1Ub29scyBDZXJ0aWZpY2F0
      ZTAdBgNVHQ4EFgQUwLakK7KelC3s4q3o1FX3/tsDoW0wDQYJKoZIhvcNAQELBQADggEBAJ7nkDTT
      /KkEIrGo7HGJl7XQo7uAZKz4dE+T9BiTTmQy/oRJWgvzMuJ6GDxaghLbFfE3FAeRLFexG40H62gP
      FINEu385NAuDZofOM8LJ9PzwsM+xcSLM/KnKjmGy00okHRVEs7uKisnYW5zhy7A6Ly/pwh0Sjd/Z
      yrc2Dakp8HYzGtKdT1vrg+ikdIv8W7P4NrInMakn5+LXd8roF0yNtCbe09dyiDCrYEyEwXQyW7KI
      Q8Xmjc8Fj05boKWDTTLZ0+CfnSop2fXI3EINYxlC1ibzZbqrie90/HSin21T0SG9xnB7tw0b+AU0
      bbG3iobVbxH5rmzYn4kF06Vbm4P/V1A=
      -----END CERTIFICATE-----
    ''
  ];
}
