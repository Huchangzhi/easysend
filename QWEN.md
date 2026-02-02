# EasySend 项目概述

## 项目简介

EasySend 是一个基于 LocalSend 的开源跨平台文件共享应用程序，增加了额外的功能和组件。它允许用户在本地网络上安全地与附近设备共享文件和消息，无需互联网连接。该项目整合了多个子系统，包括：

- **LocalSend**: 核心文件共享应用（Flutter）
- **EasyTier**: Rust 编写的去中心化虚拟网络解决方案
- **Signaling Server**: 用于设备发现的信号服务器（Rust）
- **CLI 工具**: 命令行接口工具（Dart）
- **Common 库**: 跨组件共享的通用代码（Dart）

## 架构概览

- **app/**: Flutter 主应用程序，基于 LocalSend
- **cli/**: Dart 命令行工具
- **common/**: Dart 共享库
- **core/**: Rust 核心库
- **easytier/**: EasyTier 虚拟网络解决方案
- **server/**: 信号服务器（Rust）
- **scripts/**: 构建和部署脚本

## 技术栈

- **前端/主应用**: Flutter (使用 Dart)
- **后端/核心逻辑**: Rust
- **命令行工具**: Dart
- **构建系统**: Cargo (Rust), Flutter/Dart tools
- **协议**: 基于 LocalSend 协议的本地网络通信

## 构建和运行

### 主应用程序 (Flutter)

1. 安装 Flutter (版本要求见 `.fvmrc` 文件，当前为 3.35.6)
2. 安装 Rust
3. 进入 `app` 目录
4. 运行 `flutter pub get` 下载依赖
5. 运行 `flutter run` 启动应用

```bash
cd app
flutter pub get
flutter run
```

### 信号服务器 (Rust)

```bash
cd server
cargo run
```

### EasyTier 组件 (Rust)

```bash
cd easytier
cargo run -p easytier
```

### CLI 工具 (Dart)

```bash
cd cli
dart pub get
dart run bin/cli.dart
```

## 开发约定

- 使用 Rust 和 Flutter/Dart 进行开发
- 遵循 LocalSend 的原始协议和架构模式
- 项目使用 fvm 管理 Flutter 版本
- 遵循各语言的标准编码规范

## 项目特点

1. **跨平台**: 支持 Windows、macOS、Linux、Android、iOS
2. **本地网络**: 不需要互联网连接即可工作
3. **安全性**: 使用 HTTPS 加密传输
4. **去中心化**: 基于 EasyTier 实现去中心化网络
5. **扩展性**: 包含信号服务器支持更复杂的网络拓扑

## 关键依赖

- Flutter SDK
- Rust 工具链
- fvm (Flutter Version Management)
- Cargo (Rust 包管理器)

## 用途

EasySend 可用于：
- 局域网内快速文件传输
- 无互联网连接时的设备间通信
- 构建私有虚拟网络（通过 EasyTier）
- 作为 AirDrop 的开源替代方案