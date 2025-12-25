{
    inputs,
    ...
}:
let
    inherit (inputs) haumea nixpkgs;
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    rawHosts = haumea.lib.load {
        src = ./src;
        inputs = { inherit inputs pkgs; };
    };
    hostMapFunc = name: value: { hostName = name; hostSettings = value; };
    loadedHosts = builtins.attrValues (builtins.mapAttrs hostMapFunc rawHosts );

    users = import ../user { inherit inputs pkgs; };

    hosts = builtins.listToAttrs (map ({hostName, hostSettings}@host: {
            name = hostName;
            value = nixpkgs.lib.nixosSystem {
                specialArgs = { inherit inputs; };
                system = system;
                modules = [
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
                        system.stateVersion = "25.05";
                    })
                    hostSettings.common
                ];
            };
        }) loadedHosts);

in hosts
