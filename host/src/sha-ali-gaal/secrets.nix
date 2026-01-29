{ ... }:
allenyou-secrets:

{
  zitadel-master-key = {
    file = "${allenyou-secrets}/zitadel-master-key.sha-ali-gaal.age";
    path = "/etc/zitadel/master-key";
    mode = "755";
    owner = "zitadel";
  };
  zitadel-secret-settings = {
    file = "${allenyou-secrets}/zitadel-secret-config.sha-ali-gaal.age";
    path = "/etc/zitadel/secret-settings.yml";
    mode = "755";
    owner = "zitadel";
  };
  grafana-db-password = {
    file = "${allenyou-secrets}/grafana-db-password.sha-ali-gaal.age";
    mode = "111";
  };
}
