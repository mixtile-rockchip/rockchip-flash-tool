# Rockchip Flash Tool

Rockchip Flash Tool is a cross-platform desktop application that turns Rockchip flashing into a simple, consistent user experience.

## Visual Preview

### App Interface Screenshot

![macOS UI Screenshot](docs/images/ui-screenshot.png)

## Download

- Latest release: [Download Here](https://github.com/evtest-hash/rockchip-flash-tool/releases/latest)
- All releases: [Release History](https://github.com/evtest-hash/rockchip-flash-tool/releases)

## Installation Notes

### macOS: "Developer Cannot Be Verified"

If macOS blocks the app after install, use one of these methods:

1. In Finder, right-click the app and choose **Open**.
2. Click **Open** again in the confirmation dialog.

If it is still blocked:

1. Open **System Settings** -> **Privacy & Security**.
2. In the Security section, find the blocked app message.
3. Click **Open Anyway**, then confirm.

If Gatekeeper quarantine metadata still blocks launch, run:

```bash
xattr -dr com.apple.quarantine "/Applications/Rockchip Flash Tool.app"
```

### Linux: AppImage Requires FUSE2

AppImage may show a FUSE-related error on first launch. Install FUSE2 runtime:

- Ubuntu/Debian (22.04 and earlier):

```bash
sudo apt update
sudo apt install libfuse2
```

- Ubuntu 24.04+:

```bash
sudo apt update
sudo apt install libfuse2t64
```

- Fedora:

```bash
sudo dnf install fuse-libs
```

- Arch Linux:

```bash
sudo pacman -S fuse2
```

- openSUSE:

```bash
sudo zypper install libfuse2
```

If you cannot install FUSE2 immediately, run in extract mode:

```bash
APPIMAGE_EXTRACT_AND_RUN=1 ./Rockchip-Flash-Tool-linux-x86_64.AppImage
```

## Why This Tool Exists

Rockchip flashing is often difficult for end users because many conditions change the required process.

Typical pain points:

1. Different chip models require different loader matching.
2. Devices may be in different flashing modes, and each mode needs a different flow.
3. Firmware formats are different, and the operation path changes accordingly.
4. Some platforms require extra driver preparation.
5. Users often need different tools on different operating systems.

## Design Philosophy

This tool abstracts those differences and hides unnecessary complexity.

The user-facing workflow is intentionally simple:

1. Select firmware.
2. Click **Start Flash**.

Users do not need to learn low-level flashing details to complete the task correctly.

## Core Advantages

- One consistent experience across macOS, Windows, and Linux.
- Fewer manual decisions, fewer human errors.
- Faster onboarding for new operators.
- Better operational consistency in lab, factory, and field scenarios.
