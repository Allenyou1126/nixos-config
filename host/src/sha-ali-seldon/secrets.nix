{ ... }:
allenyou-secrets:

{
  wireguardPrivateKeyFile.file = "${allenyou-secrets}/wg-private-key.sha-ali-seldon.age";
  lap-fallom-wireguardPresharedKeyFile.file = "${allenyou-secrets}/wg-psk-lap-fallom.sha-ali-seldon.age";
  home-hardin-wireguardPresharedKeyFile.file = "${allenyou-secrets}/wg-psk-home-hardin.sha-ali-seldon.age";
  lap-yenner-wireguardPresharedKeyFile.file = "${allenyou-secrets}/wg-psk-lap-yenner.sha-ali-seldon.age";
  frp-token = {
    file = "${allenyou-secrets}/frp-token.sha-ali-seldon.age";
  };
  zitadel-master-key = {
    file = "${allenyou-secrets}/zitadel-master-key.sha-ali-gaal.age";
    mode = "400";
    owner = "zitadel";
  };
  zitadel-secret-settings = {
    file = "${allenyou-secrets}/zitadel-secret-config.sha-ali-gaal.age";
    mode = "400";
    owner = "zitadel";
  };
  grafana-db-password = {
    file = "${allenyou-secrets}/grafana-db-password.sha-ali-gaal.age";
    mode = "400";
    owner = "grafana";
    group = "grafana";
  };
  deepseek-harness-secret = {
    file = "${allenyou-secrets}/deepseek-harness-secret-nginx-conf.sha-ali-seldon.age";
    mode = "400";
    owner = "nginx";
    group = "nginx";
  };
  dsh-oauth2-secret.file = "${allenyou-secrets}/deepseek-oauth2-secret.sha-ali-seldon.age";
}
