{
    inputs,
    ...
}:
let
    inherit (inputs) nixpkgs haumea;
    homeStateVersion = "25.05";
    loadToAllUsers = haumea.lib.load {
        src = ./load-to-all;
        inputs = { inherit inputs; };
    };
    userMapFunc = name: value: { userName = name; userSettings = value; };
    loadedUsers = builtins.attrValues (builtins.mapAttrs userMapFunc loadToAllUsers );
    users = {
        userHomes = builtins.listToAttrs (map ({userName, userSettings}@user: {
            name = userName;
            value = {
                home.username = userName;
                home.homeDirectory = "/home/${userName}";
                home.stateVersion = homeStateVersion;
            } // userSettings.home;
        }) loadedUsers);
        userCommons = {
            mutableUsers = false;
            users = builtins.listToAttrs (map ({userName, userSettings}@user: {
                name = userName;
                value = userSettings.common;
            }) loadedUsers);
        };
    };
in users
