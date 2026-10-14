#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_command git
require_command uv

export GIT_LFS_SKIP_SMUDGE=1
export UV_LINK_MODE="${UV_LINK_MODE:-copy}"

if [[ ! -d "${OPENPI_DIR}/.git" ]]; then
  echo "Cloning OpenPI into ${OPENPI_DIR}"
  git clone --filter=blob:none --recurse-submodules "${OPENPI_REPOSITORY}" "${OPENPI_DIR}"
fi

OPENPI_STATUS="$(git -C "${OPENPI_DIR}" status --porcelain --untracked-files=all)"
if [[ -n "${OPENPI_STATUS}" ]]; then
  if [[ "${OPENPI_STATUS}" != " M src/openpi/training/config.py" ]] || \
    ! grep -Fq 'name="pi05_libero_lora_4090"' "${OPENPI_DIR}/src/openpi/training/config.py"; then
    echo "OpenPI checkout has unexpected local changes; refusing to overwrite them." >&2
    git -C "${OPENPI_DIR}" status --short >&2
    exit 1
  fi
else
  git -C "${OPENPI_DIR}" fetch origin "${OPENPI_REF}"
  git -C "${OPENPI_DIR}" checkout --detach "${OPENPI_REF}"
  git -C "${OPENPI_DIR}" submodule update --init --recursive
fi

"${FORCEVLA_ROOT}/scripts/apply_openpi_overlay.sh"

ACTUAL_LIBERO_REF="$(git -C "${OPENPI_DIR}/third_party/libero" rev-parse HEAD)"
if [[ "${ACTUAL_LIBERO_REF}" != "${OPENPI_LIBERO_SUBMODULE_REF}" ]]; then
  echo "LIBERO submodule revision mismatch." >&2
  echo "Expected: ${OPENPI_LIBERO_SUBMODULE_REF}" >&2
  echo "Actual:   ${ACTUAL_LIBERO_REF}" >&2
  exit 1
fi

if [[ ! -e "${OPENPI_DIR}/checkpoints" ]]; then
  ln -s "${FORCEVLA_ROOT}/checkpoints" "${OPENPI_DIR}/checkpoints"
fi

(
  cd "${OPENPI_DIR}"
  GIT_LFS_SKIP_SMUDGE=1 uv sync
  GIT_LFS_SKIP_SMUDGE=1 uv pip install -e .
  uv run python -c 'from openpi.training import config; config.get_config("pi05_libero_lora_4090"); print("ForceVLA OpenPI config: OK")'
)

echo "OpenPI bootstrap completed."
echo "Pinned commit: $(git -C "${OPENPI_DIR}" rev-parse HEAD)"
