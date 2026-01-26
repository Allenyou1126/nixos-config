allenyou-secrets:

{
  nix-cache-s3-config = {
    file = "${allenyou-secrets}/oss-nix-cache-config.age";
    path = "/etc/s3/nix-cache";
    owner = "allenyou";
    mode = "0600";
  };
}
