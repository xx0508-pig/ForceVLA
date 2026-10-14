#!/usr/bin/env bash

set -euo pipefail

FORCEVLA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OPENPI_DIR="${FORCEVLA_ROOT}/third_party/openpi"

# shellcheck disable=SC1091
source "${FORCEVLA_ROOT}/configs/versions.env"

if [[ -f "${FORCEVLA_ROOT}/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "${FORCEVLA_ROOT}/.env"
  set +a
fi

export OPENPI_DATA_HOME="${OPENPI_DATA_HOME:-data/cache/openpi}"
export HF_HOME="${HF_HOME:-data/cache/huggingface}"

if [[ "${OPENPI_DATA_HOME}" != /* ]]; then
  export OPENPI_DATA_HOME="${FORCEVLA_ROOT}/${OPENPI_DATA_HOME}"
fi
if [[ "${HF_HOME}" != /* ]]; then
  export HF_HOME="${FORCEVLA_ROOT}/${HF_HOME}"
fi

export CUDA_VISIBLE_DEVICES="${CUDA_VISIBLE_DEVICES:-0}"
export MUJOCO_GL="${MUJOCO_GL:-egl}"
export XLA_PYTHON_CLIENT_MEM_FRACTION="${XLA_PYTHON_CLIENT_MEM_FRACTION:-0.90}"
export XLA_PYTHON_CLIENT_PREALLOCATE="${XLA_PYTHON_CLIENT_PREALLOCATE:-true}"
export WANDB_MODE="${WANDB_MODE:-offline}"

mkdir -p \
  "${OPENPI_DATA_HOME}" \
  "${HF_HOME}" \
  "${FORCEVLA_ROOT}/checkpoints" \
  "${FORCEVLA_ROOT}/logs" \
  "${FORCEVLA_ROOT}/outputs"

require_command() {
  local command_name="$1"
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "Missing required command: ${command_name}" >&2
    return 1
  fi
}

require_openpi() {
  if [[ ! -d "${OPENPI_DIR}/.git" ]]; then
    echo "OpenPI is not installed at ${OPENPI_DIR}. Run scripts/bootstrap_openpi.sh first." >&2
    return 1
  fi
}
