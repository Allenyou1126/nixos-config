{ ... }:
allenyou-secrets:

{
  frp-token = {
    file = "${allenyou-secrets}/frp-token.sha-ali-seldon.age";
    path = "/etc/frp/token";
    mode = "444";
  };
  deepseek-harness-secret.file = "${allenyou-secrets}/deepseek-harness-secret.home-ebeling.age";
}
