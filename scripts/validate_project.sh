#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Validating ForceVLA at ${ROOT}"

for script in "${ROOT}"/scripts/*.sh; do
  bash -n "${script}"
done

PYTHONDONTWRITEBYTECODE=1 \
  PYTHONPATH="${ROOT}/src${PYTHONPATH:+:${PYTHONPATH}}" \
  python3 -m unittest discover -s "${ROOT}/tests" -p "test_*.py" -v

git -C "${ROOT}" diff --check

echo "Project validation passed."
