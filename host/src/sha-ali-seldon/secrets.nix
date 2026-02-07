{ ... }:
allenyou-secrets:

{
  wireguardPrivateKeyFile.file = "${allenyou-secrets}/wg-private-key.sha-ali-seldon.age";
  lap-fallom-wireguardPresharedKeyFile.file = "${allenyou-secrets}/wg-psk-lap-fallom.sha-ali-seldon.age";
  home-hardin-wireguardPresharedKeyFile.file = "${allenyou-secrets}/wg-psk-home-hardin.sha-ali-seldon.age";
  frp-token = {
    file = "${allenyou-secrets}/frp-token.sha-ali-seldon.age";
    path = "/etc/frp/token";
    mode = "444";
  };
}
