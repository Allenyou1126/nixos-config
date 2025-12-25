{
    inputs,
    ...
}:
let
    haumea = inputs.haumea;
    home-manager = inputs.home-manager;
in {
    inherit haumea home-manager;
}