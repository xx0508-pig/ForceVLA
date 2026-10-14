#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_command uv
require_openpi

MODE="${1:-smoke}"
CONFIG_NAME="${FORCEVLA_CONFIG:-pi05_libero_lora_4090}"
EXPERIMENT_BASE="${FORCEVLA_EXPERIMENT:-phase1_pi05_libero_lora}"
RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)"

case "${MODE}" in
  smoke)
    NUM_STEPS="${FORCEVLA_SMOKE_STEPS:-20}"
    BATCH_SIZE="${FORCEVLA_BATCH_SIZE:-1}"
    EXPERIMENT_NAME="${EXPERIMENT_BASE}_smoke_${RUN_ID}"
    OVERWRITE=1
    ;;
  full)
    NUM_STEPS="${FORCEVLA_TRAIN_STEPS:-30000}"
    BATCH_SIZE="${FORCEVLA_BATCH_SIZE:-1}"
    EXPERIMENT_NAME="${EXPERIMENT_BASE}"
    OVERWRITE="${FORCEVLA_OVERWRITE:-0}"
    ;;
  *)
    echo "Usage: $0 [smoke|full]" >&2
    exit 2
    ;;
esac

if ! grep -Fq "name=\"${CONFIG_NAME}\"" "${OPENPI_DIR}/src/openpi/training/config.py"; then
  echo "OpenPI config ${CONFIG_NAME} is missing. Run scripts/apply_openpi_overlay.sh." >&2
  exit 1
fi

LOG_DIR="${FORCEVLA_ROOT}/logs/train"
LOG_FILE="${LOG_DIR}/${EXPERIMENT_NAME}_${RUN_ID}.log"
mkdir -p "${LOG_DIR}"

ARGS=(
  scripts/train.py
  "${CONFIG_NAME}"
  "--exp-name=${EXPERIMENT_NAME}"
  "--num-train-steps=${NUM_STEPS}"
  "--batch-size=${BATCH_SIZE}"
)
if [[ "${OVERWRITE}" == "1" ]]; then
  ARGS+=(--overwrite)
fi

echo "Mode: ${MODE}"
echo "Config: ${CONFIG_NAME}"
echo "Experiment: ${EXPERIMENT_NAME}"
echo "Steps: ${NUM_STEPS}"
echo "Batch size: ${BATCH_SIZE}"
echo "Log: ${LOG_FILE}"

(
  cd "${OPENPI_DIR}"
  uv run "${ARGS[@]}"
) 2>&1 | tee "${LOG_FILE}"

echo "Training command completed."

