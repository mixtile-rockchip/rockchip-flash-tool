from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


@dataclass
class ChipConfig:
    model: str
    usb_pids: list[int]
    loader_filenames: list[str]


_BUILTIN_CHIPS: list[ChipConfig] = [
    ChipConfig("RK3588", [0x350B], ["rk3588_spl_loader.bin"]),
    ChipConfig("RK3576", [0x350E], ["rk3576_spl_loader.bin"]),
    ChipConfig("RK3568", [0x350A], ["rk356x_spl_loader.bin"]),
    ChipConfig("RK3562", [0x350C], ["rk3562_spl_loader.bin"]),
    ChipConfig("RK3506", [0x350F], ["rk3506_spl_loader.bin"]),
    ChipConfig("RK3399", [0x330C], ["rk3399_loader.bin"]),
    ChipConfig("RK3368", [0x330A], ["rk3368_loader.bin"]),
    ChipConfig("RK3366", [0x330B], ["rk3366_loader.bin"]),
    ChipConfig("RK3328", [0x320C], ["rk3328_loader.bin", "rk322xh_loader.bin"]),
    ChipConfig("RK3326", [0x330D], ["rk3326_loader.bin", "px30_loader.bin"]),
    ChipConfig("RK3288", [0x320A], ["rk3288_loader.bin"]),
    ChipConfig("RK3229", [0x320B], ["rk322x_loader.bin"]),
    ChipConfig("RK3188", [0x310B], ["rk3188_loader.bin"]),
    ChipConfig("RK3128", [0x310C], ["rk3128_loader.bin"]),
    ChipConfig("RK3126", [0x310D], ["rk3126_loader.bin"]),
    ChipConfig("RK3066", [0x300A], ["rk3066_loader.bin"]),
    ChipConfig("RK3036", [0x301A], ["rk3036_loader.bin"]),
    ChipConfig("RK1808", [0x180A], ["rk1808_loader.bin", "rknpu_lion_loader.bin"]),
    ChipConfig("RV1126", [0x110C], ["rv1126_spl_loader.bin", "rv110x_loader.bin"]),
    ChipConfig("RV1109", [0x110B], ["rv110x_loader.bin"]),
]


class ChipDatabase:
    def __init__(self) -> None:
        self._chips = {c.model: c for c in _BUILTIN_CHIPS}
        self._pid_map = {pid: c.model for c in _BUILTIN_CHIPS for pid in c.usb_pids}

    def get_by_pid(self, pid: int) -> ChipConfig | None:
        model = self._pid_map.get(pid)
        return self._chips.get(model) if model else None

    def find_loader(self, model: str, search_dir: Path) -> Path | None:
        chip = self._chips.get(model)
        if not chip or not search_dir.exists():
            return None
        for loader_name in chip.loader_filenames:
            exact = search_dir / loader_name
            if exact.exists():
                return exact
            prefix = loader_name.removesuffix(".bin").lower()
            candidates = sorted(
                [p for p in search_dir.glob("*.bin") if p.name.lower().startswith(prefix)],
                key=lambda p: p.name.lower(),
            )
            if candidates:
                return candidates[-1]
        return None
