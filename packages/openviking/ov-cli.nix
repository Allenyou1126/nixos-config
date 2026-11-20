# ov —— OpenViking 的 Rust CLI 客户端（crates/ov_cli）。
#
# 单独构建成 `ov` 可执行文件，再由 package.nix 通过 `OV_PREBUILT_BIN_DIR`
# 预置进 Python 包：上游 setup.py 在打包时会优先使用预置二进制，而不是在
# 沙箱里再跑一次 cargo。单独暴露出来的好处是 `nix build .#ov-cli` 只构建
# 这个 CLI（Rust 依赖全部来自共享的 cargoDeps）。
{
  lib,
  rustPlatform,
  src,
  version,
  cargoDeps,
  pkg-config,
}:
let
  crate = "ov_cli";
  binary = "ov";
in
rustPlatform.buildRustPackage {
  pname = "ov-cli";
  inherit version src cargoDeps;

  # 只构建 workspace 里的 ov_cli crate（workspace 还有 ragfs / ragfs-python）。
  cargoBuildFlags = [
    "-p"
    crate
  ];

  nativeBuildInputs = [ pkg-config ];

  # reqwest 使用 rustls-tls，链接的是 rustls 而不是系统 OpenSSL，
  # 因此不需要 buildInputs = [ openssl ]。

  # 测试需要正在运行的 OpenViking 服务端，打包时不跑。
  doCheck = false;

  # crates/ov_cli/build.rs 优先读 `OPENVIKING_VERSION`，否则退回 Cargo.toml 里的
  # 0.0.0 —— 不设的话 `ov --help` 会显示 "OpenViking v0.0.0"。
  env.OPENVIKING_VERSION = version;

  meta = {
    description = "OpenViking CLI client";
    homepage = "https://github.com/volcengine/OpenViking";
    # crates/ov_cli 单独使用 Apache-2.0（主项目是 AGPL-3.0，见上游 README
    # 的 License 段与 crates/LICENSE）。
    license = lib.licenses.asl20;
    mainProgram = binary;
    platforms = [ "x86_64-linux" ];
  };
}
