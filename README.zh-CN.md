# Rockchip Flash Tool

Rockchip Flash Tool 是一款跨平台桌面应用，目标是将 Rockchip 烧录流程变成简单、一致的用户体验。

## 视觉预览

### 软件界面截图

![macOS 界面截图](docs/images/ui-screenshot.png)

## 下载

- 最新版本下载: [点此下载](https://github.com/evtest-hash/rockchip-flash-tool/releases/latest)
- 历史版本: [Release 列表](https://github.com/evtest-hash/rockchip-flash-tool/releases)

## 为什么要做这个工具

Rockchip 烧录在实际使用中经常比较复杂，因为不同条件会导致流程变化。

常见痛点包括：

1. 不同芯片型号需要匹配不同 loader。
2. 设备可能处于不同烧录模式，不同模式对应不同流程。
3. 固件格式不同，烧录路径也不同。
4. 某些平台还需要额外准备驱动环境。
5. 不同操作系统往往需要不同工具，使用体验不统一。

## 设计理念

这个工具将上述差异和复杂性在内部完成抽象，对用户隐藏不必要的技术细节。

用户侧只需要两步：

1. 选择固件。
2. 点击 **Start Flash**。

即使不了解底层烧录机制，也能完成正确操作。

## 核心优势

- macOS / Windows / Linux 三端体验一致。
- 减少人工判断步骤，降低误操作概率。
- 降低新用户学习成本。
- 提升实验室、产线和现场场景下的一致性与效率。
