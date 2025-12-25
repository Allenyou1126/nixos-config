{
    inputs,
    ...
}:
let
    inherit (inputs) nixpkgs haumea;
    system = "x86_64-linux";
    loadToAllUsers = haumea.lib.load {
        src = ./load-to-all;
        inputs = { inherit inputs; pkgs = nixpkgs.legacyPackages.${system}; };
    };
    userMapFunc = name: value: { userName = name; userSettings = value; };
    loadedUsers = builtins.attrValues (builtins.mapAttrs userMapFunc loadToAllUsers );
    users = {
        userHomes = builtins.listToAttrs (map ({userName, userSettings}@user: {
            name = userName;
            value = {
                home.username = userName;
                home.homeDirectory = "/home/${userName}";
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
