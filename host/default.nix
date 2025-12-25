{
    inputs,
    ...
}:
let
    inherit (inputs) haumea nixpkgs;
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    home-manager = inputs.home-manager;

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
                modules = [
                    ../common.nix
                    home-manager.lib.homeManagerConfiguration {
                        inherit pkgs;
                        home-manager.useGlobalPkgs = true;
                        home-manager.useUserPackages = true;
                        home-manager.extraSpecialArgs = { inherit inputs; };
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
