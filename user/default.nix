{
    inputs,
    ...
}:
let
    haumea = inputs.haumea;
    home-manager = import inputs.home-manager.nixosModules.home-manager;
    rawUsers = haumea.lib.load {
        src = ./src;
        inputs = { inherit inputs; };
    };
    userMapFunc = name: value: { userName = name; userSettings = value; };
    loadedUsers = builtins.attrValues (builtins.mapAttrs userMapFunc rawUsers);
    users = {
        userHomes = home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = inputs;
            home-manager.users = builtins.listToAttrs (map ({userName, userSettings}@user: {
                name = userName;
                value = {
                    home.username = userName;
                    home.homeDirectory = "/home/${userName}";
                } // userSettings.home;
            }) loadedUsers);
        };
        userCommons = {
            mutableUsers = false;
            users = builtins.listToAttrs (map ({userName, userSettings}@user: {
                name = userName;
                value = userSettings.common;
            }) loadedUsers);
        };
    };
in users