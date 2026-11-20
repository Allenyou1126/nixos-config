# openviking —— 主包：Python 服务端 + 内嵌 C++17 向量引擎 + 预置的 ov / ragfs_python。
#
# 搬运自 github:Daaboulex/openviking-nix 的 package.nix（MIT），按本仓库格式重写，
# 逻辑保持一致：上游 setup.py 负责构建，Nix 这边只做三件它做不到的事 ——
#
#   1. 用 `OV_PREBUILT_BIN_DIR` 注入单独构建好的 `ov`（避免在 Python 构建沙箱里再跑 cargo）；
#   2. 用 `OV_SKIP_RAGFS_BUILD=1` + 预置的 `ragfs_python` 扩展跳过 maturin 构建；
#   3. 把 pyproject 里过紧的版本约束放宽（nixpkgs 的依赖版本与上游 pin 不会完全一致）。
#
# 产物（`$out/bin`）：`openviking-server`、`openviking`、`ov`、`openviking-gateway`，
# 以及 Python 库 `openviking` / `openviking_cli` 等。上游的 `vikingbot` 入口点需要
# `[bot]` extra（依赖数量大且部分不在 nixpkgs），本包不提供 —— 见 postInstall 的注释。
{
  lib,
  python3Packages,
  fetchurl,
  cmake,
  src,
  version,
  ov-cli,
  ragfs-python,
}:

let
  # ---- 不在 nixpkgs 里的 PyPI wheel 依赖 ------------------------------------
  # 上游把若干依赖直接以 wheel 形式进 nix store。hash 是对应 PyPI wheel 的
  # sha256，升级 OpenViking 时要对照上游 pyproject.toml 检查并同步。

  # tree-sitter 语法绑定：nixpkgs 缺这几个包。用 manylinux 预编译 wheel，
  # 避免语法 C 源码与 nixpkgs 里 tree-sitter 的 parser.h ABI 不匹配。
  mkTreeSitterWheel =
    {
      pname,
      grammarVersion,
      url,
      hash,
    }:
    python3Packages.buildPythonPackage {
      inherit pname;
      version = grammarVersion;
      format = "wheel";
      src = fetchurl { inherit url hash; };
      dependencies = [ python3Packages.tree-sitter ];
      doCheck = false;
      meta.license = lib.licenses.mit;
    };

  tree-sitter-typescript = mkTreeSitterWheel {
    pname = "tree-sitter-typescript";
    grammarVersion = "0.23.2";
    url = "https://files.pythonhosted.org/packages/49/d1/a71c36da6e2b8a4ed5e2970819b86ef13ba77ac40d9e333cb17df6a2c5db/tree_sitter_typescript-0.23.2-cp39-abi3-manylinux_2_5_x86_64.manylinux1_x86_64.manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
    hash = "sha256-6W02uFvKzeuP9cJhjXVZPvEuuvG06s40d+K9squxdSw=";
  };
  tree-sitter-java = mkTreeSitterWheel {
    pname = "tree-sitter-java";
    grammarVersion = "0.23.5";
    url = "https://files.pythonhosted.org/packages/29/09/e0d08f5c212062fd046db35c1015a2621c2631bc8b4aae5740d7adb276ad/tree_sitter_java-0.23.5-cp39-abi3-manylinux_2_5_x86_64.manylinux1_x86_64.manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
    hash = "sha256-NwsgS5UAuEf20MWtWEBFgxzuaemj5Nh4U1055KfkxPE=";
  };
  tree-sitter-cpp = mkTreeSitterWheel {
    pname = "tree-sitter-cpp";
    grammarVersion = "0.23.4";
    url = "https://files.pythonhosted.org/packages/6a/4d/23e390234d2acd351f5563b1079c515d7c1fe13ddb7392cee543be74dda3/tree_sitter_cpp-0.23.4-cp39-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
    hash = "sha256-dz0sr8CLvA+Zhof6M/QvN4waNxzbWChwxNE6uwYJJwY=";
  };
  tree-sitter-go = mkTreeSitterWheel {
    pname = "tree-sitter-go";
    grammarVersion = "0.25.0";
    url = "https://files.pythonhosted.org/packages/86/fb/b30d63a08044115d8b8bd196c6c2ab4325fb8db5757249a4ef0563966e2e/tree_sitter_go-0.25.0-cp310-abi3-manylinux1_x86_64.manylinux_2_28_x86_64.manylinux_2_5_x86_64.whl";
    hash = "sha256-BLOzy0r/GOdOKNSbcWxvJMtx3f3WZ2iYfibk0PqBL3Q=";
  };
  tree-sitter-php = mkTreeSitterWheel {
    pname = "tree-sitter-php";
    grammarVersion = "0.24.1";
    url = "https://files.pythonhosted.org/packages/9a/c6/fd863a7a779d0ab67688939eba0e08bff7b1ffe731288d3d3610df21217b/tree_sitter_php-0.24.1-cp310-abi3-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl";
    hash = "sha256-ehQEow8pckmKzgQLAClzi42sRdChKTLMuLYF65S6++Q=";
  };
  tree-sitter-lua = mkTreeSitterWheel {
    pname = "tree-sitter-lua";
    grammarVersion = "0.5.0";
    url = "https://files.pythonhosted.org/packages/45/2b/1edfd9bef9a1cc11047cd87ca9c60707b8425080cfc0498a7d3bc762d783/tree_sitter_lua-0.5.0-cp310-abi3-manylinux1_x86_64.manylinux_2_28_x86_64.manylinux_2_5_x86_64.whl";
    hash = "sha256-XsRIyFT+oyQUoESRR9ZIvFut33oDVwCMSr4yads1Nwo=";
  };

  firecrawl-anydoc = python3Packages.buildPythonPackage {
    pname = "firecrawl-anydoc";
    version = "0.2.4";
    format = "wheel";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/fc/16/feeca9705bfdb237f1cb69ede0b373b144c0d51df4297e595a74b815557e/firecrawl_anydoc-0.2.4-cp310-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl";
      hash = "sha256-DlrtAb9tTlxYjTNjiIKT8s7rn+sARJoy4LqZN5fPC9M=";
    };
    doCheck = false;
    pythonImportsCheck = [ "anydoc" ];
    meta.license = lib.licenses.mit;
  };

  # lark-oapi（飞书开放平台 SDK）不在 nixpkgs 里。
  lark-oapi = python3Packages.buildPythonPackage {
    pname = "lark-oapi";
    version = "1.6.5";
    format = "wheel";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/40/28/a425593c6de71b80ad642ed8e624468a2848ea0e4ad7cb32a8380941fd7f/lark_oapi-1.6.5-py3-none-any.whl";
      hash = "sha256-pW+lSK69rpw27wEU+7xuXQBOsuFTmOEc+IpXN/DPhkE=";
    };
    dependencies = with python3Packages; [
      requests
      requests-toolbelt
      pycryptodome
      protobuf
      websockets
      httpx
    ];
    # lark-oapi 把 websockets 锁在 <16，而 nixpkgs 是 16.0（上游自己也不满足）。
    pythonRelaxDeps = [ "websockets" ];
    doCheck = false;
    meta.license = lib.licenses.mit;
  };

  # opentelemetry-instrumentation-asyncio：nixpkgs 没有单独打包。
  # 版本必须跟随本仓库 nixpkgs 的 opentelemetry-* 栈（wheel 内部用 == 锁死了
  # 同族包，不一致时运行期依赖检查会直接报错）。nixos-26.05 的栈是
  # opentelemetry-api 1.34.0 / opentelemetry-instrumentation 0.55b0，
  # 因此用 0.55b0 的 wheel —— 参考仓库针对 nixos-unstable 用的是 0.64b0。
  opentelemetry-instrumentation-asyncio = python3Packages.buildPythonPackage {
    pname = "opentelemetry-instrumentation-asyncio";
    version = "0.55b0";
    format = "wheel";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/82/71/64ed9dc18c278fd153a09af240c46dbbcf13244b76c256c9c6798c2faf1d/opentelemetry_instrumentation_asyncio-0.55b0-py3-none-any.whl";
      hash = "sha256-Mnj/iWSHfOFjiLuvZGV6pt+j5ewHF1WD7XINN89KVpE=";
    };
    dependencies = with python3Packages; [
      opentelemetry-api
      opentelemetry-instrumentation
      opentelemetry-semantic-conventions
      wrapt
    ];
    doCheck = false;
    meta.license = lib.licenses.asl20;
  };

  # 火山引擎 SDK（字节跳动云服务，纯 Python）。
  volcengine = python3Packages.buildPythonPackage {
    pname = "volcengine";
    version = "1.0.217";
    format = "wheel";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/28/ea/2801b15e71fc571404b8204bb5d0b80ca94d4e325e07a73848788cfa5d97/volcengine-1.0.217-py3-none-any.whl";
      hash = "sha256-PwBDcTwYtKFlf3aKyMNVBgkfAm1pgtkq+MHjf5OQb04=";
    };
    # "google>=3.0.0" 是个误导性依赖 —— volcengine 实际用的是 google.protobuf。
    nativeBuildInputs = [ python3Packages.pythonRelaxDepsHook ];
    pythonRemoveDeps = [ "google" ];
    dependencies = with python3Packages; [
      protobuf
      pycryptodome
      pytz
      requests
      retry
      six
    ];
    doCheck = false;
    meta.license = lib.licenses.asl20;
  };

  volcengine-python-sdk = python3Packages.buildPythonPackage {
    pname = "volcengine-python-sdk";
    version = "5.0.16";
    format = "wheel";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/87/f2/ebafb985b6bce5ecef36367be985e80dcd7f3f73d1fdd54c16a25a4a3d88/volcengine_python_sdk-5.0.16-py2.py3-none-any.whl";
      hash = "sha256-ioVWPzpI3FGiQ/6Xg14N5ZbhXtZ9O8Dw4+lS9TBRUfs=";
    };
    dependencies = with python3Packages; [
      certifi
      python-dateutil
      six
      urllib3
      # pyproject 里的 [ark] extra 依赖
      pydantic
      httpx
      anyio
      cryptography
    ];
    doCheck = false;
    meta.license = lib.licenses.asl20;
  };

  # openviking-sdk：上游在 0.4.5 拆分出来的独立 Python HTTP 客户端，
  # 现在是主包的运行时依赖（PyPI 纯 Python wheel）。
  openviking-sdk = python3Packages.buildPythonPackage {
    pname = "openviking-sdk";
    version = "0.1.12";
    format = "wheel";
    src = fetchurl {
      url = "https://files.pythonhosted.org/packages/37/76/2acad2f8a9d3e9db0d0e970a5082c793bd8efe322c42e64e8d03c79884f5/openviking_sdk-0.1.12-py3-none-any.whl";
      hash = "sha256-apRlrtT7Q7GNYsX0YXvNCyAJIzVfOaX9qm5SUQ2DPFQ=";
    };
    dependencies = [ python3Packages.httpx ];
    doCheck = false;
    meta.license = lib.licenses.asl20;
  };
in

python3Packages.buildPythonApplication {
  pname = "openviking";
  inherit version src;
  pyproject = true;

  env = {
    # setuptools-scm 需要一个版本号（源码来自 GitHub tarball，没有 .git）；
    # build_support/versioning.py 也会读 OPENVIKING_VERSION。
    SETUPTOOLS_SCM_PRETEND_VERSION = version;
    OPENVIKING_VERSION = version;
    # C++ 向量引擎的 SIMD 变体（x86_profiles.py 总会另外构建 sse3 基线）。
    # 只构建 avx2：目标机器都支持，少一个变体可以显著缩短编译时间。
    OV_X86_BUILD_VARIANTS = "avx2";
    # ragfs_python 已由 ragfs-python.nix 预构建并注入（见 preBuild），跳过 maturin。
    # OV_REQUIRE_RAGFS_BUILD=0 是必需的：bdist_wheel 路径默认认为「跳过 ragfs
    # 产物」是硬错误。
    OV_SKIP_RAGFS_BUILD = "1";
    OV_REQUIRE_RAGFS_BUILD = "0";
  };

  postPatch = ''
    # 从 PEP 517 build-system requires 里去掉 cmake 与 maturin：cmake 由
    # nativeBuildInputs 提供，ragfs_python 注入预构建产物（不会跑 maturin）。
    substituteInPlace pyproject.toml \
      --replace-fail '"cmake>=3.15",' "" \
      --replace-fail '"maturin>=1.0,<2.0",' ""
  '';

  preBuild = ''
    # 注入预构建的 ov CLI，setup.py 会跳过 cargo build（OV_PREBUILT_BIN_DIR）。
    mkdir -p prebuilt
    cp ${ov-cli}/bin/ov prebuilt/
    export OV_PREBUILT_BIN_DIR=$(pwd)/prebuilt

    # 注入预构建的 ragfs_python 扩展：setup.py 的 package-data 会把
    # `lib/ragfs_python*.so` 打进 wheel，这里先放进源码树。
    mkdir -p openviking/lib
    cp ${ragfs-python}/${python3Packages.python.sitePackages}/ragfs_python/ragfs_python*.so openviking/lib/
  '';

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
    pybind11
    wheel
  ];

  # C++ pybind11 向量引擎由 setup.py 调 cmake 构建。
  nativeBuildInputs = [ cmake ];
  dontUseCmakeConfigure = true;

  # pyproject.toml 的版本 pin 很紧（litellm<1.91.2、python-multipart>=0.0.31 等），
  # nixpkgs 的包集不会完全匹配 —— 全部放宽，而不是逐个追。
  pythonRelaxDeps = true;

  # 上游的 C++ 代码用了 -Wno-format，与 NixOS 加固的 -Werror=format-security
  # 在 GCC 15+ 上冲突。
  hardeningDisable = [ "format" ];

  dependencies =
    (with python3Packages; [
      # 核心
      pydantic
      typing-extensions
      pyyaml
      httpx
      requests
      urllib3
      loguru
      cryptography
      argon2-cffi
      pathspec

      # LLM / AI
      openai
      litellm
      mcp

      # 服务端
      fastapi
      uvicorn
      python-multipart

      # gateway extra（0.5.0 的 [gateway] 依赖，打包后 openviking-gateway 可用）
      aiohttp
      async-timeout
      orjson
      packaging

      # 认证 extra：[auth] 里的 python-jose（OIDC 插件 import 它）。LDAP 组件
      # 需要 python-ldap → openldap，依赖链太重且属于可选功能，未打包；需要
      # LDAP 时自行 override 补上 `python-ldap`。
      python-jose

      # 文档解析
      pdfplumber
      pdfminer-six
      python-docx
      python-pptx
      openpyxl
      olefile
      xlrd
      ebooklib
      readabilipy
      markdownify

      # Feed / XML（vikingbot hooks，0.4.6 起）
      feedparser
      defusedxml

      # 网页抓取（0.4.9 起）
      scrapy
      trafilatura

      # 代码解析（tree-sitter）
      tree-sitter
      tree-sitter-python
      tree-sitter-javascript
      tree-sitter-rust
      tree-sitter-c-sharp
      tree-sitter-language-pack
      grep-ast

      # 可观测性
      opentelemetry-api
      opentelemetry-sdk
      opentelemetry-exporter-otlp-proto-grpc
      opentelemetry-exporter-otlp-proto-http

      # 工具
      json-repair
      apscheduler
      xxhash
      rapidfuzz
      jinja2
      tabulate
      protobuf
      typer
    ])
    ++ [
      # 不在 nixpkgs 的 tree-sitter 语法（预编译 wheel）
      tree-sitter-typescript
      tree-sitter-java
      tree-sitter-cpp
      tree-sitter-go
      tree-sitter-php
      tree-sitter-lua

      # 其他不在 nixpkgs 的 PyPI wheel 依赖
      firecrawl-anydoc
      lark-oapi
      opentelemetry-instrumentation-asyncio

      # 火山引擎 SDK
      volcengine
      volcengine-python-sdk

      # 上游独立的 HTTP SDK（0.4.5 起）
      openviking-sdk

      # Rust RAGFS 的 PyO3 绑定（同时预置进 openviking/lib/）
      ragfs-python
    ];

  # 上游测试需要运行中的服务端 + 网络 + API key。
  doCheck = false;

  # ragfs_python 的模块初始化会 import openviking.storage.errors，因此只有
  # 在 openviking 自己的环境里扩展才可加载 —— 检查放在这里。
  pythonImportsCheck = [
    "openviking"
    "ragfs_python"
  ];

  # 确认原生产物确实进了包。
  postInstall = ''
    site=$out/lib/python*/site-packages/openviking
    test -f $site/bin/ov || { echo "ERROR: ov binary not found in package" >&2; exit 1; }
    test -f "$(echo $site/lib/ragfs_python*.so)" || { echo "ERROR: ragfs_python extension not found in package" >&2; exit 1; }

    # vikingbot 需要上游的 [bot] extra（prompt-toolkit、rich、langfuse、各种 IM SDK、
    # sandbox 运行时等 30+ 个依赖，其中不少不在 nixpkgs），这里不打包 —— 不删掉这个
    # 入口点的话，用户拿到的是一个 import 就失败的命令。`openviking-server --with-bot`
    # 同样不可用，模块也不暴露它。
    rm -f $out/bin/vikingbot $out/bin/.vikingbot-wrapped
  '';

  meta = {
    description = "OpenViking — agent-native context database for AI agents";
    homepage = "https://github.com/volcengine/OpenViking";
    # 上游按组件分许可：主项目 AGPL-3.0，crates/ov_cli 与 crates/ragfs 是
    # Apache-2.0（见上游 README 的 License 段）。本包同时内置两者，故都列出。
    license = [
      lib.licenses.agpl3Only
      lib.licenses.asl20
    ];
    mainProgram = "openviking-server";
    platforms = [ "x86_64-linux" ];
  };
}
