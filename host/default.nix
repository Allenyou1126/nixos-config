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

    users = import ../user { inherit inputs; };

    hosts = builtins.listToAttrs (map ({hostName, hostSettings}@host: {
            name = hostName;
            value = nixpkgs.lib.nixosSystem {
                specialArgs = {inherit inputs;};
                modules = [
                    ../common.nix
                    home-manager.nixosModules.home-manager {
                        home-manager.useGlobalPkgs = true;
                        home-manager.useUserPackages = true;
                        home-manager.extraSpecialArgs = inputs;
                        home-manager.users = users.userHomes;
                    }
                    ({ ... }: {
                        users = users.userCommons;
                        networking.hostName = hostName;
                        system.stateVersion = "25.05";
                    })
                    hostSettings.common
                    hostSettings.hardware-configuration
                ];
            };
        }) loadedHosts);

in hosts
