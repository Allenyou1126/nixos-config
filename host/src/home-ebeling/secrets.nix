{ ... }:
allenyou-secrets:

{
  frp-token = {
    file = "${allenyou-secrets}/frp-token.sha-ali-seldon.age";
    path = "/etc/frp/token";
    mode = "444";
  };
}
