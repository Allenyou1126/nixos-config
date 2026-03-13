allenyou-secrets:

{
  nix-cache-s3-config = {
    file = "${allenyou-secrets}/oss-nix-cache-config.age";
    path = "/home/allenyou/.aws/config";
    owner = "allenyou";
    mode = "0600";
  };
  aliyun-cli-config = {
    file = "${allenyou-secrets}/aliyun-cli-config.age";
    path = "/home/allenyou/.aliyun/config.json";
    owner = "allenyou";
    mode = "0600";
  };
}
