#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_openpi

CONFIG_FILE="${OPENPI_DIR}/src/openpi/training/config.py"
PATCH_FILE="${FORCEVLA_ROOT}/configs/openpi/pi05_libero_lora_4090.patch"
ACTUAL_REF="$(git -C "${OPENPI_DIR}" rev-parse HEAD)"

if [[ "${ACTUAL_REF}" != "${OPENPI_REF}" ]]; then
  echo "Refusing to patch an unreviewed OpenPI revision." >&2
  echo "Expected: ${OPENPI_REF}" >&2
  echo "Actual:   ${ACTUAL_REF}" >&2
  exit 1
fi

if grep -Fq 'name="pi05_libero_lora_4090"' "${CONFIG_FILE}"; then
  echo "OpenPI overlay is already applied."
  exit 0
fi

git -C "${OPENPI_DIR}" apply --check "${PATCH_FILE}"
git -C "${OPENPI_DIR}" apply "${PATCH_FILE}"

grep -Fq 'name="pi05_libero_lora_4090"' "${CONFIG_FILE}"
echo "Applied ForceVLA OpenPI config overlay."

