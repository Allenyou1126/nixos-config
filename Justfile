host := ""

hostArg := if host == "" { "" } else { "#" + host }

# Display command list
default:
  @just --list

# Build and switch to a new generation
# usage: just switch
switch:
  sudo nixos-rebuild switch --flake .$(hostArg)

# Build and switch to a new generation using cn mirrors.
# usage: just switch-cn
switch-cn:
  sudo nixos-rebuild switch --flake .$(hostArg) --override-input nixpkgs "git+https://mirrors.nju.edu.cn/git/nixpkgs.git?ref=nixos-25.11&shallow=1" --override-input home-manager "git+https://gitee.com/Allenyou1126/home-manager?ref=release-25.11&shallow=1"

up:
  nix flake update

# Update specific input
# usage: make upp i=home-manager
upp:
  nix flake update $(i)

repl:
  nix repl -f flake:nixpkgs

clean:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

gc:
  sudo nix store gc --debug
  sudo nix-collect-garbage --delete-old