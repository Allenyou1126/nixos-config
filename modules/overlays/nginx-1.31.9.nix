# TODO(2026-11-19): 临时 overlay，仅用于将 nginxMainline 从 1.31.8 提升到 1.31.9，
# 以修复 CVE-2026-123633 / CVE-2026-123007。
#
# 移除条件：nixos-26.05 分支中的 nginxMainline 已达到 1.31.9。
# 检查命令：
#   nix eval --raw github:NixOS/nixpkgs/nixos-26.05#legacyPackages.x86_64-linux.nginxMainline.version
# 满足条件后：
#   1. 删除本文件；
#   2. 移除 host/default.nix 中对本 overlay 的 import。
# 请在下次修改 flake.lock / 升级 nixpkgs 之前先检查并移除本 overlay。
final: prev: {
  nginxMainline = prev.nginxMainline.overrideAttrs (_: {
    version = "1.31.9";
    nginxVersion = "1.31.9";
    src = prev.fetchurl {
      url = "https://nginx.org/download/nginx-1.31.9.tar.gz";
      hash = "sha256-oRxe7uLiV/RHjw5kn4SwBAeH0nfS0+UjOVKqa23LgK0=";
    };
  });
}
