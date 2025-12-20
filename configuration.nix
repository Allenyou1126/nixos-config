{ config, lib, pkgs, ... }:

{
	imports = [
		./hardware-configuration.nix
    ];

	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;
	networking.hostName = "nixos-server";

	time.timeZone = "Asia/Shanghai";
	nix.settings.experimental-features = ["nix-command" "flakes"];

	i18n.defaultLocale = "en_US.UTF-8";

	users.users.allenyou = {
		isNormalUser = true;
		extraGroups = [ "wheel" ];
		packages = with pkgs; [
			tree
		];
		openssh.authorizedKeys.keys = [
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILFhiR8t5soqwfpcemRLTe9StCSGsD36TyJgE9PGcjJk cfan7@Allenyou-Laptop"
		];
	};

	environment.systemPackages = with pkgs; [
		vim
		wget
		git
	];
	environment.variables.EDITOR = "vim";


	services.openssh = {
		enable = true;
		settings = {
			PermitRootLogin = "no";
			PasswordAuthentication = false;
		};
		ports = [ 2333 ];
		openFirewall = true;
	};

	nix.settings.substituters = [
		"https://mirrors.ustc.edu.cn/nix-channels/store"
	];
	system.stateVersion = "25.05";

}

