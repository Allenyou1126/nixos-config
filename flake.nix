{
	description = "Allenyou's NixOS Server Flake";

	inputs = {
		nixpkgs.url = "git+https://mirrors.nju.edu.cn/git/nixpkgs.git?ref=nixos-25.11&shallow=1";
		home-manager = {
			url = "git+https://gitee.com/Allenyou1126/home-manager?ref=release-25.11&shallow=1";
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
