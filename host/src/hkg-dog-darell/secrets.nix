{ ... }:
allenyou-secrets:

{
  wireguard-private-key-file.file = "${allenyou-secrets}/wg-private-key.hkg-dog-darell.age";
  miniflux-database-url = {
    file = "${allenyou-secrets}/miniflux-database-url.hkg-dog-darell.age";
    mode = "0444";
  };
  vaultwarden-secrets = {
    file = "${allenyou-secrets}/vaultwarden-secret.hkg-dog-darell.age";
    mode = "0444";
  };
  wakapi-password-salt.file = "${allenyou-secrets}/wakapi-password-salt.hkg-dog-darell.age";
  wakapi-smtp-password.file = "${allenyou-secrets}/wakapi-smtp-password.hkg-dog-darell.age";
  wakapi-database-password.file = "${allenyou-secrets}/wakapi-database-password.hkg-dog-darell.age";
  # waline-secrets.file = "${allenyou-secrets}/waline-secrets.hkg-dog-darell.age";
  # waline-zlight106-secrets.file = "${allenyou-secrets}/waline-zlight106-secrets.hkg-dog-darell.age";
  umami-app-secret = {
    file = "${allenyou-secrets}/umami-app-secret.hkg-dog-darell.age";
    mode = "0444";
  };
  umami-database-url = {
    file = "${allenyou-secrets}/umami-database-url.hkg-dog-darell.age";
    mode = "0444";
  };
  webdav-password.file = "${allenyou-secrets}/webdav-password.hkg-dog-darell.age";
}
