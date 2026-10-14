#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_command uv
require_openpi

CONFIG_NAME="${FORCEVLA_CONFIG:-pi05_libero_lora_4090}"
RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)"
LOG_DIR="${FORCEVLA_ROOT}/logs/norm_stats"
LOG_FILE="${LOG_DIR}/${CONFIG_NAME}_${RUN_ID}.log"
mkdir -p "${LOG_DIR}"

(
  cd "${OPENPI_DIR}"
  uv run scripts/compute_norm_stats.py --config-name "${CONFIG_NAME}"
) 2>&1 | tee "${LOG_FILE}"

echo "Normalization statistics completed. Log: ${LOG_FILE}"

