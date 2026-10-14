#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

require_command docker
require_openpi

TASK_SUITE="${LIBERO_TASK_SUITE:-libero_10}"
RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)"
LOG_DIR="${FORCEVLA_ROOT}/logs/eval"
LOG_FILE="${LOG_DIR}/pi05_libero_${TASK_SUITE}_${RUN_ID}.log"
OUTPUT_DIR="${FORCEVLA_ROOT}/outputs/libero/${TASK_SUITE}_${RUN_ID}"
mkdir -p "${LOG_DIR}"
mkdir -p "${OUTPUT_DIR}"

export SERVER_ARGS="${SERVER_ARGS:---env LIBERO}"
export CLIENT_ARGS="${CLIENT_ARGS:---args.task-suite-name ${TASK_SUITE} --args.video-out-path /forcevla_outputs/${TASK_SUITE}_${RUN_ID}}"
export FORCEVLA_OUTPUTS="${FORCEVLA_ROOT}/outputs/libero"

echo "Evaluating pretrained pi0.5-LIBERO on ${TASK_SUITE}"
echo "SERVER_ARGS=${SERVER_ARGS}"
echo "CLIENT_ARGS=${CLIENT_ARGS}"
echo "Outputs: ${OUTPUT_DIR}"

(
  cd "${OPENPI_DIR}"
  docker compose \
    -f examples/libero/compose.yml \
    -f "${FORCEVLA_ROOT}/configs/docker/libero.outputs.yml" \
    up --build
) 2>&1 | tee "${LOG_FILE}"

echo "Evaluation command completed. Log: ${LOG_FILE}"
