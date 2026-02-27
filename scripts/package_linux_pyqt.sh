#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="${APP_NAME:-Rockchip-Flash-Tool}"
APPIMAGE_NAME="${APPIMAGE_NAME:-Rockchip-Flash-Tool-linux-x86_64.AppImage}"
VENV_DIR="${VENV_DIR:-.venv-linux}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
ICON_PNG="${ICON_PNG:-assets-icon-1024.png}"

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

python -m PyInstaller \
  --noconfirm \
  --clean \
  --windowed \
  --name "$APP_NAME" \
  --add-data "tools:tools" \
  --add-data "rkbin:rkbin" \
  rk_flash_tool/__main__.py

APPDIR="dist/AppDir"
APPDIR_ABS="$ROOT_DIR/$APPDIR"
rm -rf "$APPDIR"
mkdir -p "$APPDIR/usr/opt/$APP_NAME" "$APPDIR/usr/bin" "$APPDIR/usr/share/applications" "$APPDIR/usr/share/icons/hicolor/256x256/apps"

cp -R "dist/$APP_NAME/"* "$APPDIR/usr/opt/$APP_NAME/"
ln -sf "../opt/$APP_NAME/$APP_NAME" "$APPDIR/usr/bin/$APP_NAME"

cat > "$APPDIR/AppRun" <<EOF
#!/usr/bin/env bash
HERE="\$(dirname "\$(readlink -f "\$0")")"
APP_BASE="\$HERE/usr/opt/$APP_NAME"
QT_PLUGIN_DIR=""

if [[ -d "\$APP_BASE/_internal/PySide6/Qt/plugins" ]]; then
  QT_PLUGIN_DIR="\$APP_BASE/_internal/PySide6/Qt/plugins"
elif [[ -d "\$APP_BASE/PyQt5/Qt5/plugins" ]]; then
  QT_PLUGIN_DIR="\$APP_BASE/PyQt5/Qt5/plugins"
fi

export LD_LIBRARY_PATH="\$HERE/usr/lib:\$APP_BASE:\$APP_BASE/_internal:\$APP_BASE/_internal/PySide6/Qt/lib:\${LD_LIBRARY_PATH:-}"
if [[ -n "\$QT_PLUGIN_DIR" ]]; then
  export QT_PLUGIN_PATH="\$QT_PLUGIN_DIR:\${QT_PLUGIN_PATH:-}"
  export QT_QPA_PLATFORM_PLUGIN_PATH="\$QT_PLUGIN_DIR/platforms"
fi
exec "\$HERE/usr/bin/$APP_NAME" "\$@"
EOF
chmod +x "$APPDIR/AppRun"

cp "$ICON_PNG" "$APPDIR/.DirIcon"
cp "$ICON_PNG" "$APPDIR/rockchip-flash-tool.png"
cp "$ICON_PNG" "$APPDIR/usr/share/icons/hicolor/256x256/apps/rockchip-flash-tool.png"

cat > "$APPDIR/rockchip-flash-tool.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Rockchip Flash Tool
Exec=$APP_NAME
Icon=rockchip-flash-tool
Categories=Utility;
Terminal=false
StartupNotify=true
EOF
cp "$APPDIR/rockchip-flash-tool.desktop" "$APPDIR/usr/share/applications/rockchip-flash-tool.desktop"

# Bundle as many runtime shared libs as possible for Qt/xcb portability.
mkdir -p "$APPDIR/usr/lib"
declare -A seen

copy_one_dep() {
  local src="$1"
  [[ -n "$src" ]] || return 0
  [[ -e "$src" ]] || return 0
  [[ "$src" = "$APPDIR_ABS"* ]] && return 0

  case "$(basename "$src")" in
    linux-vdso.so.1|ld-linux*.so*|libc.so.6|libm.so.6|libpthread.so.0|librt.so.1|libdl.so.2|libutil.so.1)
      return 0
      ;;
  esac

  [[ -n "${seen[$src]:-}" ]] && return 0
  seen["$src"]=1

  local base
  base="$(basename "$src")"
  cp -L "$src" "$APPDIR/usr/lib/$base"

  while read -r dep; do
    copy_one_dep "$dep"
  done < <(ldd "$src" 2>/dev/null | awk '{for(i=1;i<=NF;i++){if($i ~ /^\//){print $i}}}' | sort -u)
}

APP_BIN="$APPDIR/usr/opt/$APP_NAME/$APP_NAME"
if [[ -x "$APP_BIN" ]]; then
  copy_one_dep "$APP_BIN"
fi

while IFS= read -r f; do
  copy_one_dep "$f"
done < <(find "$APPDIR/usr/opt/$APP_NAME" -type f \( -name "*.so" -o -name "*.so.*" -o -name "libqxcb*.so" \))

# Explicitly include common xcb libs that are frequently missing on target hosts.
for f in \
  /usr/lib/x86_64-linux-gnu/libxcb-cursor.so.0 \
  /usr/lib/x86_64-linux-gnu/libxcb-xkb.so.1 \
  /usr/lib/x86_64-linux-gnu/libxcb-util.so.1 \
  /usr/lib/x86_64-linux-gnu/libxcb-image.so.0 \
  /usr/lib/x86_64-linux-gnu/libxcb-icccm.so.4 \
  /usr/lib/x86_64-linux-gnu/libxcb-keysyms.so.1 \
  /usr/lib/x86_64-linux-gnu/libxkbcommon-x11.so.0 \
  /usr/lib/x86_64-linux-gnu/libxcb-shape.so.0 \
  /usr/lib/x86_64-linux-gnu/libxcb-render-util.so.0 \
  /usr/lib/x86_64-linux-gnu/libxkbcommon.so.0 \
  /usr/lib/x86_64-linux-gnu/libxcb.so.1
do
  copy_one_dep "$f"
done

APPIMAGETOOL="$ROOT_DIR/.cache/appimagetool-x86_64.AppImage"
mkdir -p "$ROOT_DIR/.cache"
if [[ ! -f "$APPIMAGETOOL" ]]; then
  curl -L -o "$APPIMAGETOOL" "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
  chmod +x "$APPIMAGETOOL"
fi

ARCH=x86_64 APPIMAGE_EXTRACT_AND_RUN=1 "$APPIMAGETOOL" "$APPDIR" "dist/$APPIMAGE_NAME"
chmod +x "dist/$APPIMAGE_NAME"
echo "Done: dist/$APPIMAGE_NAME"
