host := ""

hostArg := if host == "" { "" } else { "#" + host }

# Display command list
default:
  @just --list

# Build and switch to a new generation
# usage: just switch host=hostname(leave empty for default)
switch:
  sudo nixos-rebuild switch --flake .$(hostArg)

# Build and switch to a new generation using cn mirrors.
# usage: just switch-cn host=hostname(leave empty for default)
switch-cn:
  sudo nixos-rebuild switch --flake .$(hostArg) --override-input nixpkgs "git+https://mirrors.nju.edu.cn/git/nixpkgs.git?ref=nixos-25.11&shallow=1" --override-input home-manager "git+https://gitee.com/Allenyou1126/home-manager?ref=release-25.11&shallow=1"

# Update all flake inputs
# usage: just update
update:
  nix flake update

# Update specific input
# usage: just update-specific i=home-manager
update-specific:
  nix flake update $(i)

# Enter nix repl
# usage: just repl
repl:
  nix repl -f flake:nixpkgs

# Clean up old profiles(only keep the last 7 days)
# usage: just clean
clean:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d

# Clean up old generations
# usage: just gc
gc:
  sudo nix store gc --debug
  sudo nix-collect-garbage --delete-old