{
	description = "Allenyou's NixOS Server Flake";

	inputs = {
		nixpkgs.url = "git+https://mirrors.nju.edu.cn/git/nixpkgs.git?ref=nixos-25.05&shallow=1";
		home-manager = {
			url = "git+https://gitee.com/Allenyou1126/home-manager?ref=release-25.05&shallow=1";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		haumea = {
			url = "github:nix-community/haumea/v0.2.2";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, home-manager, ... }@inputs: let
			users = import ./user { inherit inputs; };
		in {
			debug = import ./test.nix { inherit inputs; };
			nixosConfigurations = {
				sha-ali-gaal = nixpkgs.lib.nixosSystem {
					specialArgs = {inherit inputs;};
					modules = [
						./ssh.nix
						./nix-store-mirror.nix
						./boot/efi-systemd.nix
						./hardware-configuration.nix
						./common.nix
						./nix-store-mirror.nix
						# users.userHomes
						home-manager.nixosModules.home-manager {
							home-manager.useGlobalPkgs = true;
							home-manager.useUserPackages = true;
							home-manager.extraSpecialArgs = inputs;
							home-manager.users = {
								allenyou = {
									home.username = "allenyou";
									home.homeDirectory = "/home/allenyou";
								} // (import ./user/src/allenyou.nix).home;
							};
						}
						({pkgs, ...}: {
							environment.systemPackages = with pkgs; [
								vim
								wget
								git
							];
							environment.variables.EDITOR = "vim";
							users = users.userCommons;
							system.stateVersion = "25.05";
							networking.hostName = "sha-ali-gaal";
						})
					];
				};
			};
		};
}
