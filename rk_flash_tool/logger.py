from __future__ import annotations

import logging
from pathlib import Path


def get_log_path() -> Path:
    log_dir = Path.home() / ".rk-flash-tool" / "logs"
    log_dir.mkdir(parents=True, exist_ok=True)
    return log_dir / "rk_flash_tool.log"


def setup_logging() -> None:
    log_path = get_log_path()
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
        handlers=[
            logging.FileHandler(log_path, encoding="utf-8"),
            logging.StreamHandler(),
        ],
    )
