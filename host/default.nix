{
    inputs,
    ...
}:
let
    inherit (inputs) haumea nixpkgs agenix allenyou-secrets;
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    rawHosts = haumea.lib.load {
        src = ./src;
        inputs = { inherit inputs pkgs; };
    };
    hostMapFunc = name: value: { hostName = name; hostSettings = value; };
    loadedHosts = builtins.attrValues (builtins.mapAttrs hostMapFunc rawHosts );

    users = import ../user { inherit inputs pkgs; };

    hosts = builtins.listToAttrs (map ({hostName, hostSettings}@host: let
        secrets = hostSettings.secrets or {};
    in {
        name = hostName;
        value = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit inputs; };
            system = system;
            modules = [
                agenix.nixosModules.default
                ../modules/secrets.nix
                inputs.home-manager.nixosModules.home-manager
                {
                    home-manager = {
                        useGlobalPkgs = true;
                        useUserPackages = true;
                        extraSpecialArgs = { inherit inputs; };
                        users = users.userHomes;
                    };
                }
                ({ ... }: {
                    users = users.userCommons;
                    networking.hostName = hostName;
                    environment.systemPackages = [ agenix.packages.${system}.default ];
                })
                ({ ... }: {
                    age.secrets = secrets;
                })
                hostSettings.common
            ];
        };
    }) loadedHosts);

in hosts
