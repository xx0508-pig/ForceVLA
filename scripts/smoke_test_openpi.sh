#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_command uv
require_openpi

RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)"
LOG_DIR="${FORCEVLA_ROOT}/logs/smoke"
LOG_FILE="${LOG_DIR}/openpi_debug_${RUN_ID}.log"
mkdir -p "${LOG_DIR}"

(
  cd "${OPENPI_DIR}"
  uv run python -c 'import jax, torch; print("JAX devices:", jax.devices()); print("PyTorch CUDA:", torch.cuda.is_available(), torch.cuda.get_device_name(0) if torch.cuda.is_available() else "none")'
  uv run scripts/train.py debug --exp-name="forcevla_smoke_${RUN_ID}" --overwrite
) 2>&1 | tee "${LOG_FILE}"

echo "OpenPI smoke test completed. Log: ${LOG_FILE}"

