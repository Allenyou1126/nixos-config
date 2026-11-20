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
  deepseek-harness-secret.file = "${allenyou-secrets}/deepseek-harness-secret-nginx-conf.sha-ali-seldon.age";
  dsh-oauth2-cookie-secret.file = "${allenyou-secrets}/deepseek-oauth2-cookie-secret.sha-ali-seldon.age";
}
