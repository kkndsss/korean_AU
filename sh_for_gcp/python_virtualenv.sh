#!/usr/bin/env bash
# python_virtualenv.sh - interactive suppressed when vars provided
# if PYTHON_VERSION or VENV_NAME env vars are set, no prompt will appear.

set -euo pipefail

# If full_install uses PY_VER, accept it too
PYTHON_VERSION="${PYTHON_VERSION:-${PY_VER:-3.11.8}}"
VENV_NAME="${VENV_NAME:-my_env}"
VENV_DIR="${VENV_DIR:-.venv}"

echo "[python_virtualenv.sh] PYTHON_VERSION=${PYTHON_VERSION}, VENV_NAME=${VENV_NAME}, VENV_DIR=${VENV_DIR}"

# If variables were not set, prompt (keeps backward-compatibility)
if [ -z "${PYTHON_VERSION:-}" ]; then
  read -p "Enter the version of Python you want to install (e.g., 3.11.x): " PYTHON_VERSION
fi

if [ -z "${VENV_NAME:-}" ]; then
  read -p "Enter the name for the virtual environment: " VENV_NAME
fi

# If pyenv present, prefer pyenv virtualenv
if command -v pyenv >/dev/null 2>&1; then
  echo "[python_virtualenv.sh] pyenv detected. Ensuring ${PYTHON_VERSION} and virtualenv ${VENV_NAME}."

  pyenv install -s "${PYTHON_VERSION}" || true

  # create virtualenv if missing
  if pyenv virtualenvs --bare 2>/dev/null | grep -q "^${VENV_NAME}\$"; then
    echo "[python_virtualenv.sh] pyenv virtualenv '${VENV_NAME}' exists. Skipping creation."
  else
    if pyenv virtualenv --help >/dev/null 2>&1; then
      pyenv virtualenv "${PYTHON_VERSION}" "${VENV_NAME}" || true
    else
      # fallback: create filesystem venv under ~/.pyenv/versions (best-effort)
      PY_BIN="${HOME}/.pyenv/versions/${PYTHON_VERSION}/bin/python"
      if [ -x "${PY_BIN}" ]; then
        TMPDIR="$(mktemp -d)"
        "${PY_BIN}" -m venv "${TMPDIR}/${VENV_NAME}" || true
        echo "[python_virtualenv.sh] Created fallback venv at ${TMPDIR}/${VENV_NAME}"
      else
        echo "[python_virtualenv.sh] Warning: ${PY_BIN} not found; cannot create fallback venv." >&2
      fi
    fi
  fi

  echo "[python_virtualenv.sh] To use: pyenv activate ${VENV_NAME} or set PYENV_VERSION=${VENV_NAME}"
  exit 0
fi

# Fallback: system python venv
echo "[python_virtualenv.sh] pyenv not found; using system python."

PY_CMD=""
if command -v python3 >/dev/null 2>&1; then
  PY_CMD="python3"
elif command -v python >/dev/null 2>&1; then
  PY_CMD="python"
else
  echo "[python_virtualenv.sh] ERROR: no python interpreter found." >&2
  exit 1
fi

if [ -d "${VENV_DIR}" ]; then
  echo "[python_virtualenv.sh] Virtualenv directory '${VENV_DIR}' already exists. Skipping creation."
else
  echo "[python_virtualenv.sh] Creating venv at '${VENV_DIR}' using ${PY_CMD}..."
  "${PY_CMD}" -m venv "${VENV_DIR}"
fi

if [ -f "${VENV_DIR}/bin/pip" ]; then
  echo "[python_virtualenv.sh] Upgrading pip/setuptools/wheel..."
  "${VENV_DIR}/bin/pip" install --upgrade pip setuptools wheel >/dev/null 2>&1 || true
fi

echo "[python_virtualenv.sh] Done. Activate with: source ${VENV_DIR}/bin/activate"
exit 0
