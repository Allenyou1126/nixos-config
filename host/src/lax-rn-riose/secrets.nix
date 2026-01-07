{ allenyou-secrets, ... }:

{
    wireguardPrivateKeyFile.file = ${allenyou-secrets}/wg-private-key.lax-rn-riose.age;
}