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
			specialArgs = {inherit inputs;};
			modules = [
				./ssh.nix
				./nix-store-mirror.nix
				./boot/efi-systemd.nix
				./hardware-configuration.nix
				./common.nix
				./nix-store-mirror.nix
				home-manager.nixosModules.home-manager {
					home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
                    home-manager.users.allenyou = import ./home/allenyou.nix;
                    home-manager.extraSpecialArgs = inputs;
				}
				({pkgs, ...}: {
					environment.systemPackages = with pkgs; [
						vim
						wget
						git
					];
					environment.variables.EDITOR = "vim";

					system.stateVersion = "25.05";
					networking.hostName = "nixos-server";
					users.users.allenyou = import ./user/allenyou.nix;
				})
			];
		};
	};
}
