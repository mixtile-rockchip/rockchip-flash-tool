#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="Rockchip Flash Tool"
DMG_NAME="${DMG_NAME:-Rockchip-Flash-Tool-macOS-universal.dmg}"
ICON_PNG="${ICON_PNG:-assets-icon-1024.png}"
ICON_ICNS="${ICON_ICNS:-assets/icon.icns}"
TARGET_ARCH="${TARGET_ARCH:-universal2}"
DEPLOY_TARGET="${DEPLOY_TARGET:-10.15}"
VENV_DIR="${VENV_DIR:-}"
PYTHON_BIN="${PYTHON_BIN:-}"

if [[ "$TARGET_ARCH" == "universal2" ]]; then
  # /usr/bin/python3 is a universal binary on macOS and avoids arm64-only Homebrew Python issues.
  VENV_DIR="${VENV_DIR:-.venv-universal2}"
  PYTHON_BIN="${PYTHON_BIN:-/usr/bin/python3}"
else
  VENV_DIR="${VENV_DIR:-.venv}"
  PYTHON_BIN="${PYTHON_BIN:-python3}"
fi

cd "$ROOT_DIR"

if [[ ! -d "$VENV_DIR" ]]; then
  "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"
python -m pip install -U pip
pip install --no-compile -r requirements.txt pyinstaller

if [[ ! -f "$ICON_PNG" ]]; then
  echo "Icon source not found: $ICON_PNG"
  exit 1
fi

# Rebuild icon when missing, when source changed, or when explicitly requested.
if [[ ! -f "$ICON_ICNS" || "$ICON_PNG" -nt "$ICON_ICNS" || "${FORCE_ICON_REBUILD:-0}" == "1" ]]; then
  bash "scripts/make_icns.sh" "$ICON_PNG" "$ICON_ICNS"
fi

export MACOSX_DEPLOYMENT_TARGET="$DEPLOY_TARGET"

python -m PyInstaller \
  --noconfirm \
  --clean \
  --windowed \
  --target-arch "$TARGET_ARCH" \
  --name "$APP_NAME" \
  --icon "$ICON_ICNS" \
  --add-data "tools:tools" \
  --add-data "rkbin:rkbin" \
  rk_flash_tool/__main__.py

STAGE_DIR="dist/dmg-stage"
rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR"
cp -R "dist/${APP_NAME}.app" "$STAGE_DIR/"
ln -s /Applications "$STAGE_DIR/Applications"

hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$STAGE_DIR" \
  -ov \
  -format UDZO \
  "dist/${DMG_NAME}"

rm -rf "$STAGE_DIR"
echo "Done: dist/${DMG_NAME}"
