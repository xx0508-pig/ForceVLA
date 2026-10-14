from __future__ import annotations

import os
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class ProjectLayoutTest(unittest.TestCase):
    def test_required_paths_exist(self) -> None:
        required = [
            "README.md",
            ".gitignore",
            ".env.example",
            "configs/versions.env",
            "configs/experiments/phase1_pi05_libero.yaml",
            "scripts/bootstrap_openpi.sh",
            "scripts/doctor.sh",
            "data",
            "checkpoints",
            "logs",
            "outputs",
            "src/forcevla",
        ]
        missing = [item for item in required if not (ROOT / item).exists()]
        self.assertEqual(missing, [], f"Missing project paths: {missing}")

    def test_runtime_directories_are_git_ignored(self) -> None:
        probes = [
            "data/raw/example.hdf5",
            "data/cache/openpi/example.ckpt",
            "checkpoints/model/params",
            "logs/train.log",
            "outputs/evaluation.mp4",
            "third_party/openpi/README.md",
            ".env",
        ]
        env = os.environ.copy()
        for probe in probes:
            result = subprocess.run(
                ["git", "check-ignore", "-q", probe],
                cwd=ROOT,
                env=env,
                check=False,
            )
            self.assertEqual(result.returncode, 0, f"Expected Git to ignore {probe}")


if __name__ == "__main__":
    unittest.main()

