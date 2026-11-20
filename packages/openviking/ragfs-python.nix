# ragfs-python —— RAGFS（Rust 重写的 AGFS）的 PyO3 Python 绑定。
#
# 用 maturin 把 crates/ragfs-python 构建成 abi3 扩展模块（ragfs_python.abi3.so），
# 再由 package.nix 预置进 openviking 包（上游 setup.py 的
# `OV_SKIP_RAGFS_BUILD=1` 路径）。Rust 依赖来自共享的 cargoDeps。
#
# 注意：这个扩展的 `#[pymodule]` 初始化会 import `openviking.storage.errors`，
# 而 openviking 又依赖它，所以这里**不能**做 import check —— 唯一的可加载环境
# 是 openviking 自己的 runtime，检查放在 package.nix 的 pythonImportsCheck。
{
  lib,
  python3Packages,
  rustPlatform,
  rustc,
  cargo,
  pkg-config,
  openssl,
  src,
  cargoDeps,
}:

python3Packages.buildPythonPackage {
  pname = "ragfs-python";
  # 这个 crate 独立于 OpenViking 发版（crates/ragfs-python/Cargo.toml），
  # nixpkgs 的 pythonMetadataCheckPhase 会用它和 wheel 的 METADATA 比对，
  # 上游 bump 版本时会在这里报错，避免打出一个「版本是假的」包。
  version = "0.1.0";
  inherit src cargoDeps;
  pyproject = true;

  # maturin 项目在 workspace 的子目录里。
  buildAndTestSubdir = "crates/ragfs-python";

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
    cargo
    pkg-config
  ];

  buildInputs = [ openssl ];

  # 用系统 OpenSSL，避免 vendored 构建（上游 fred/rustls 相关修复的等价设置）。
  env.OPENSSL_NO_VENDOR = 1;

  # 测试需要可写的文件系统后端，打包时不跑。
  doCheck = false;

  meta = {
    description = "PyO3 Python bindings for RAGFS — the Rust AGFS filesystem";
    homepage = "https://github.com/volcengine/OpenViking";
    # crates/ragfs 的 Cargo.toml 声明 Apache-2.0（主项目是 AGPL-3.0）。
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
  };
}
