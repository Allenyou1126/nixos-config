{
    inputs,
    pkgs,
    ...
}:
let
    inherit (inputs) nixpkgs haumea;
    lib = nixpkgs.lib;
    loadToAllUsers = haumea.lib.load {
        src = ./load-to-all;
        inputs = { inherit inputs pkgs; };
    };
    userMapFunc = name: value: { userName = name; userSettings = value; };
    loadedUsers = builtins.attrValues (builtins.mapAttrs userMapFunc loadToAllUsers );
    users = {
        userHomes = builtins.listToAttrs (map ({userName, userSettings}@user: {
            name = userName;
            value = lib.recursiveUpdate {
                home.username = userName;
                home.homeDirectory = "/home/${userName}";
            } userSettings.home;
        }) loadedUsers);
        userHomesClient = builtins.listToAttrs (map ({userName, userSettings}@user: {
            name = userName;
            value = lib.recursiveUpdate {
                home.username = userName;
                home.homeDirectory = "/home/${userName}";
            } (lib.recursiveUpdate userSettings.home (userSettings.home-client or {}));
        }) loadedUsers);
        userCommons = {
            mutableUsers = false;
            users = builtins.listToAttrs (map ({userName, userSettings}@user: {
                name = userName;
                value = userSettings.common;
            }) loadedUsers);
        };
        userCommonsClient = {
            mutableUsers = false;
            users = builtins.listToAttrs (map ({userName, userSettings}@user: {
                name = userName;
                value = lib.recursiveUpdate userSettings.common (userSettings.common-client or {});
            }) loadedUsers);
        };
    };
in users
