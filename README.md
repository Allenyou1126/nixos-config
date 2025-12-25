# Allenyou's NixOS Configuration

这里是 Allenyou 的 NixOS Configuration 仓库，未来会有更多运维相关的内容被存放在这里。

## 主机名

### 规则

代号一般取人名，用于设备的代号优先取科幻作品中的。

#### 远程服务器

```
[三位机场码]-[服务商]-[代号]
```

目前的服务商代号列表：

- `ali`: 阿里云
- `rn`: RackNerd
- `dog`: 狗云

#### 家里云

```
home-[代号]
```

#### 个人设备

```
lap-[代号]
desk-[代号]
```

### 目前命名表

| 主机名         | 类型          | 服务商   | 地域                  | 系统         | 描述                                |
| -------------- | ------------- | -------- | --------------------- | ------------ | ----------------------------------- |
| hkg-dog-darell | 云服务器      | 狗云     | 香港                  | Ubuntu 22.04 | 主力服务器，大部分应用              |
| sha-ali-gaal   | 云服务器      | 阿里云   | 上海                  | NixOS        | 99 计划机子，测试用                 |
| sha-ali-seldon | 云服务器      | 阿里云   | 上海                  | Debian 12    | 内网穿透 + 个人主页                 |
| lax-rn-riose   | 云服务器      | RackNerd | 洛杉矶                | Ubuntu 22.04 | DN42 BGP                            |
| home-demerzel  | 家里云-实体机 | -        | 家里                  | Proxmox VE   | 虚拟化                              |
| home-arkady    | 家里云-虚拟机 | -        | 家里 on home-demerzel | Windows 11   | 远程桌面                            |
| home-ebeling   | 家里云-虚拟机 | -        | 家里 on home-demerzel | Debian 12    | 内网服务器                          |
| home-hardin    | 家里云-实体机 | -        | 家里                  | OpenWRT      | 软路由                              |
| lap-fallom     | 个人设备      | -        | -                     | Windows 11   | 拯救者 R9000P 2023 锐龙版，主力设备 |

## 部署方式

首先，正常安装 NixOS，生成好 `hardwware-configuration.nix`，并启用 Flakes。

随后，生成私钥并添加到 GitHub，然后 clone 该仓库到 `~/nixos-config`，将原本的配置文件夹备份后删除，将该目录链接过去。

在 `host/src/` 目录下新建名为主机名的目录，将 `hardwware-configuration.nix` 移动到其中，`configuration.nix` 精简后命名为 `common.nix` 移动到其中。

随后，运行 `nixos-rebuild switch --flake .#【主机名】` 即可。
