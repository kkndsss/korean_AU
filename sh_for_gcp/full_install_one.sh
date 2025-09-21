#!/bin/bash
# full_install_safe.sh
# Usage: sudo bash full_install_safe.sh <l4|t4|v100> <GIT_REPO_URL>
# Two-phase idempotent installer:
#  - Phase A: install GPU driver/CUDA (pre-reboot) and create sentinel
#  - Reboot (once) to activate drivers
#  - Phase B: post-reboot installs (pyenv, python venv, clone repo, deps)
set -euo pipefail

# Optional: enable logging to /var/log/full_install.log
# exec > >(tee -a /var/log/full_install.log) 2>&1

GPU_TYPE=${1:-""}
GIT_REPO_URL=${2:-""}
SENTINEL="/var/local/cuda_preinstall_done"

if [ -z "$GPU_TYPE" ]; then
  echo "Usage: $0 <l4|t4|v100> <GIT_REPO_URL>"
  exit 2
fi

echo "=== full_install_safe.sh START ==="
echo "GPU_TYPE=${GPU_TYPE}"
if [ -n "$GIT_REPO_URL" ]; then
  echo "GIT_REPO_URL=${GIT_REPO_URL}"
fi
echo "Sentinel path: ${SENTINEL}"
echo ""

# helper checks
nvidia_ok() {
  if command -v nvidia-smi >/dev/null 2>&1; then
    if nvidia-smi >/dev/null 2>&1; then
      return 0
    fi
  fi
  return 1
}

cuda_ok() {
  if command -v nvcc >/dev/null 2>&1; then
    nvcc --version >/dev/null 2>&1 && return 0
  fi
  if [ -d /usr/local/cuda-12.2 ] || [ -d /usr/local/cuda ]; then
    return 0
  fi
  return 1
}

# ---------------- Phase A: pre-reboot (install GPU driver / CUDA) ----------------
if [ ! -f "$SENTINEL" ]; then
  echo "[Phase A] Sentinel not found -> checking CUDA/driver..."

  if nvidia_ok && cuda_ok; then
    echo "[Phase A] NVIDIA driver and CUDA already present. Creating sentinel and skipping install."
    sudo mkdir -p "$(dirname "$SENTINEL")"
    sudo touch "$SENTINEL"
    sudo chown root:root "$SENTINEL"
    echo "[Phase A] Sentinel created at $SENTINEL"
  else
    echo "[Phase A] Running cuda_install.sh for GPU type: $GPU_TYPE"
    if [ ! -f "./cuda_install.sh" ]; then
      echo "Error: cuda_install.sh not found in current directory. Place it here or run from its directory."
      exit 3
    fi
    chmod +x ./cuda_install.sh

    # Instruct cuda scripts to NOT reboot themselves (full_install handles reboot).
    echo "[Phase A] Calling cuda_install.sh with SKIP_REBOOT=1 ..."
    SKIP_REBOOT=1 ./cuda_install.sh "$GPU_TYPE" || {
      echo "[Phase A] cuda_install.sh returned non-zero. Inspect logs."
      exit 4
    }

    # Re-check
    if nvidia_ok && cuda_ok; then
      echo "[Phase A] CUDA/driver installation appears successful."
      sudo mkdir -p "$(dirname "$SENTINEL")"
      sudo touch "$SENTINEL"
      sudo chown root:root "$SENTINEL"
      echo "[Phase A] Sentinel created at $SENTINEL"
      echo "[Phase A] Rebooting to activate drivers (only one reboot)."
      sudo reboot
    else
      echo "[Phase A] After installer, CUDA/driver not detected. Please check logs and re-run."
      exit 5
    fi
  fi
else
  echo "[Phase A] Sentinel exists -> skipping GPU install."
fi

# ---------------- Phase B: post-reboot setup ----------------
echo "[Phase B] Starting post-reboot steps..."

# dependencies_install.sh
if [ -f "./dependencies_install.sh" ]; then
  chmod +x ./dependencies_install.sh
  echo "[Phase B] Running dependencies_install.sh ..."
  ./dependencies_install.sh
else
  echo "[Phase B] dependencies_install.sh not found; skipping."
fi

# pyenv_setup.sh
if [ -f "./pyenv_setup.sh" ]; then
  chmod +x ./pyenv_setup.sh
  echo "[Phase B] Running pyenv_setup.sh ..."
  ./pyenv_setup.sh
else
  echo "[Phase B] pyenv_setup.sh not found; skipping."
fi

# Create / activate python environment (pyenv preferred)
PY_VER="${PYTHON_VERSION:-3.11.8}"
VENV_NAME="${VENV_NAME:-my_env}"

if command -v pyenv >/dev/null 2>&1; then
  echo "[Phase B] Using pyenv. Ensuring python $PY_VER and virtualenv $VENV_NAME ..."
  pyenv install -s "$PY_VER"
  # pyenv-virtualenv may be used; try to create if not exists
  if ! pyenv virtualenvs --bare | grep -q "^${VENV_NAME}\$"; then
    pyenv virtualenv "$PY_VER" "$VENV_NAME" || true
  fi
  eval "$(pyenv init --path)" 2>/dev/null || true
  pyenv activate "$VENV_NAME" || true
else
  echo "[Phase B] pyenv not found. Make sure system python $PY_VER is installed or install pyenv manually."
fi

# python_virtualenv.sh (optional)
if [ -f "./python_virtualenv.sh" ]; then
  chmod +x ./python_virtualenv.sh
  echo "[Phase B] Running python_virtualenv.sh ..."
  ./python_virtualenv.sh
fi

# clone repo
if [ -n "$GIT_REPO_URL" ]; then
  REPO_DIR="$(basename "$GIT_REPO_URL" .git)"
  if [ ! -d "$REPO_DIR" ]; then
    echo "[Phase B] Cloning repository $GIT_REPO_URL ..."
  else
    echo "[Phase B] Repo $REPO_DIR already exists; skipping clone."
  fi
else
  echo "[Phase B] No GIT_REPO_URL provided; skipping clone."
fi

echo "=== full_install_safe.sh COMPLETE (Phase B done) ==="
echo "If you need to force Phase A again, remove sentinel: sudo rm -f ${SENTINEL}"
exit 0
