{
	description = "Allenyou's NixOS Server Flake";

	inputs = {
		nixpkgs.url = "git+https://mirrors.nju.edu.cn/git/nixpkgs.git?ref=nixos-25.05&shallow=1";
		home-manager = {
			url = "git+https://gitee.com/Allenyou1126/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, home-manager, ... }@inputs: {
		nixosConfigurations.nixos-server = nixpkgs.lib.nixosSystem {
			modules = [
				./configuration.nix
				home-manager.nixosModules.home-manager {
					home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
                    home-manager.users.allenyou = import ./home.nix;
                    home-manager.extraSpecialArgs = inputs;
				}
			];
		};
	};
}
