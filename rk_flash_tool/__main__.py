from __future__ import annotations

import sys
from pathlib import Path

from PySide6.QtGui import QIcon
from PySide6.QtWidgets import QApplication

from rk_flash_tool import __app_name__
from rk_flash_tool.logger import setup_logging
from rk_flash_tool.main_window import MainWindow


def _resolve_icon_path() -> Path | None:
    base_dirs = []
    meipass = getattr(sys, "_MEIPASS", None)
    if meipass:
        base_dirs.append(Path(meipass))
    base_dirs.append(Path(__file__).resolve().parent.parent)

    platform_icon = "icon.ico" if sys.platform.startswith("win") else "icon.icns"
    for base in base_dirs:
        p = base / "assets" / platform_icon
        if p.exists():
            return p
    return None


def main() -> None:
    setup_logging()
    app = QApplication(sys.argv)
    app.setStyle("Fusion")
    app.setApplicationName(__app_name__)
    icon_path = _resolve_icon_path() if sys.platform.startswith("win") else None
    if icon_path:
        app.setWindowIcon(QIcon(str(icon_path)))
    w = MainWindow()
    if icon_path:
        w.setWindowIcon(QIcon(str(icon_path)))
    w.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
