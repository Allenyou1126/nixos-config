{
  inputs,
  ...
}:
let
  inherit (inputs)
    haumea
    nixpkgs
    agenix
    allenyou-secrets
    ;
  system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};

  rawHosts = haumea.lib.load {
    src = ./src;
    inputs = { inherit inputs pkgs; };
  };
  hostMapFunc = name: value: {
    hostName = name;
    hostSettings = value;
  };
  loadedHosts = builtins.attrValues (builtins.mapAttrs hostMapFunc rawHosts);

  users = import ../user { inherit inputs pkgs; };

  commonSecrets = import ./secrets.nix allenyou-secrets;

  hosts = builtins.listToAttrs (
    map (
      { hostName, hostSettings }:
      let
        secrets = hostSettings.secrets or (allenyou-secrets: { });
      in
      {
        name = hostName;
        value = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          };
          system = system;
          modules = [
            {
              nixpkgs.overlays = [
                # TODO(2026-11-19): 临时 overlay，将 nginxMainline 提升到 1.31.9。
                # 在下次修改 flake.lock / 升级 nixpkgs 前检查 nixos-26.05 是否已提供 1.31.9，
                # 若已提供则移除此 import 并删除 modules/overlays/nginx-1.31.9.nix。
                (import ../modules/overlays/nginx-1.31.9.nix)
              ];
              nixpkgs.config.allowUnfree = true;
            }
            agenix.nixosModules.default
            ../modules/secrets.nix
            ../modules/binary-cache
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                users = if hostSettings.is-client or false then users.userHomesClient else users.userHomes;
              };
            }
            (
              { ... }:
              {
                users = if hostSettings.is-client or false then users.userCommonsClient else users.userCommons;
                networking.hostName = hostName;
                environment.systemPackages = [ agenix.packages.${system}.default ];
              }
            )
            (
              { ... }:
              {
                age.secrets = (secrets allenyou-secrets) // commonSecrets;
              }
            )
            hostSettings.common
          ];
        };
      }
    ) loadedHosts
  );

in
hosts
