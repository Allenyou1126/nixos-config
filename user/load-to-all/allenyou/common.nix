{ ... }:

{
  isNormalUser = true;
  extraGroups = [ "wheel" ];
  hashedPassword = "$6$LUaEhWcWLrsJap7N$OiTNNYisJvE8kKwXlgw8gwixmmWQqbVHiXtNnaF9nHw/UegFSz22ofr5NDiQwuGKCQXTRTUTew1owOZpY2hxk0";
  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFhiR8t5soqwfpcemRLTe9StCSGsD36TyJgE9PGcjJk allenyou@lap-fallom"
  ];
}
