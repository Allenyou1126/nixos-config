# Display command list
default:
  @just --list --justfile {{justfile()}} --list-heading $"Allenyou's Justfile Commands\n"

# Build and switch to a new generation. Usage: just switch hostname(leave empty for default)
switch host="" *extraArg:
  nixos-rebuild switch --flake .{{ if host == "" { "" } else  { "#" + host } }} --sudo {{ extraArg }}

# Build and switch to a new generation using cn mirrors. Usage: just switch-cn hostname(leave empty for default)
switch-cn host="" *extraArg: (switch host "--override-input nixpkgs \"git+https://mirrors.nju.edu.cn/git/nixpkgs.git?ref=nixos-25.11&shallow=1\" --override-input home-manager \"git+https://gitee.com/Allenyou1126/home-manager?ref=release-25.11&shallow=1\" "+extraArg)

# Sign a path. Usage: just sign path
sign path:
  nix store sign --recursive --key-file ~/.config/nix/secret.key {{ path }}

# upload package to s3 nix cache. Usage: just upload package
upload package:
  nix copy --to 's3://allenyou-nix-cache?scheme=https&endpoint=f624bd145eb9d5917615aa6f0dc4bc34.r2.cloudflarestorage.com&profile=nix-cache' {{ package }}

# Update all flake inputs. Usage: just update
update-all: (update "")

# Update specific input. Usage: just update input
update input:
  nix flake update {{input}}

# Enter nix repl. Usage: just repl
repl:
  nix repl -f flake:nixpkgs

# Clean up old profiles(only keep the last 7 days). Usage: just clean
clean:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d

# Clean up old generations. Usage: just gc
gc:
  sudo nix store gc --debug
  sudo nix-collect-garbage --delete-old
