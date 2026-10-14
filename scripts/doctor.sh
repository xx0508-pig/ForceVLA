#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

failures=0

check_command() {
  local name="$1"
  if command -v "${name}" >/dev/null 2>&1; then
    echo "[OK] ${name}: $(command -v "${name}")"
  else
    echo "[MISSING] ${name}"
    failures=$((failures + 1))
  fi
}

echo "ForceVLA system check"
echo "Root: ${FORCEVLA_ROOT}"
echo "OS: $(uname -srmo)"
echo "Disk: $(df -h "${FORCEVLA_ROOT}" | awk 'NR==2 {print $4 " free of " $2}')"

check_command git
check_command git-lfs
check_command uv
check_command nvidia-smi

if command -v docker >/dev/null 2>&1; then
  echo "[OK] docker: $(docker --version)"
  if docker info >/dev/null 2>&1; then
    echo "[OK] Docker daemon is reachable"
  else
    echo "[WARN] Docker is installed but the daemon is not reachable by this user"
  fi
else
  echo "[WARN] Docker is missing; OpenPI training can work, but the recommended LIBERO evaluation path cannot"
fi

if command -v nvidia-smi >/dev/null 2>&1; then
  echo "GPU inventory:"
  nvidia-smi --query-gpu=index,name,memory.total,memory.free,driver_version --format=csv,noheader
fi

if [[ -d "${OPENPI_DIR}/.git" ]] && command -v uv >/dev/null 2>&1; then
  echo "OpenPI commit: $(git -C "${OPENPI_DIR}" rev-parse HEAD)"
  if [[ -d "${OPENPI_DIR}/.venv" ]]; then
    (
      cd "${OPENPI_DIR}"
      uv run python -c 'import jax, torch; print("JAX:", jax.__version__, jax.devices()); print("PyTorch:", torch.__version__, "CUDA:", torch.cuda.is_available())'
    )
  else
    echo "[INFO] OpenPI checkout exists, but its uv environment has not been created"
  fi
else
  echo "[INFO] OpenPI is not installed yet"
fi

echo "OPENPI_DATA_HOME=${OPENPI_DATA_HOME}"
echo "HF_HOME=${HF_HOME}"
echo "MUJOCO_GL=${MUJOCO_GL}"

if (( failures > 0 )); then
  echo "System check found ${failures} missing required command(s)." >&2
  exit 1
fi

echo "System check completed. Review any warnings above before training."

