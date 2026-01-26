allenyou-secrets:

{
  nix-cache-s3-config = {
    file = "${allenyou-secrets}/oss-nix-cache-config.age";
    path = "/home/allenyou/.aws/config";
    owner = "allenyou";
    mode = "0600";
  };
}
