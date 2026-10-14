"""Canonical repository paths used by ForceVLA scripts and future Python tools."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class ProjectPaths:
    """Resolve project-owned paths without depending on the current directory."""

    root: Path

    @classmethod
    def discover(cls) -> "ProjectPaths":
        return cls(Path(__file__).resolve().parents[2])

    @property
    def data(self) -> Path:
        return self.root / "data"

    @property
    def checkpoints(self) -> Path:
        return self.root / "checkpoints"

    @property
    def logs(self) -> Path:
        return self.root / "logs"

    @property
    def outputs(self) -> Path:
        return self.root / "outputs"

    @property
    def openpi(self) -> Path:
        return self.root / "third_party" / "openpi"

    def ensure_runtime_directories(self) -> None:
        for path in (self.data, self.checkpoints, self.logs, self.outputs):
            path.mkdir(parents=True, exist_ok=True)

