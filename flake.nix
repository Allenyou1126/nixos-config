{
	description = "Allenyou's NixOS Server Flake";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
		home-manager = {
			url = "github:nix-community/home-manager/release-25.11";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		haumea = {
			url = "github:nix-community/haumea/v0.2.2";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		agenix = {
			url = "github:ryantm/agenix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, ... }@inputs: let
		hosts = import ./host { inherit inputs; };
	in {
		nixosConfigurations = hosts;
	};
}
