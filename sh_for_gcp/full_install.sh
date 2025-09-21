#!/bin/bash

echo "=== AI 개발환경 자동화 설치 스크립트 (CUDA/pyenv/venv 등) ==="

# ---------------- CUDA & NVIDIA DRIVER 부분 -----------------
if nvidia-smi &> /dev/null; then
    echo "[확인] CUDA 및 NVIDIA 드라이버가 이미 설치되어 있습니다. (nvidia-smi OK)"
else
    echo "GPU 종류를 선택하세요."
    echo "1) L4"
    echo "2) T4"
    echo "3) V100"
    read -p "선택 (1/2/3): " GPU_CHOICE

    case $GPU_CHOICE in
        1) GPU_TYPE="l4" ;;
        2) GPU_TYPE="t4" ;;
        3) GPU_TYPE="v100" ;;
        *) echo "잘못 입력했습니다. 스크립트를 다시 실행하세요."; exit 1 ;;
    esac

    echo ">> $GPU_TYPE 타입 GPU용 CUDA/NVIDIA 드라이버 설치를 시작합니다."
    bash cuda_install.sh $GPU_TYPE

    echo ">> CUDA 설치가 끝났습니다. 시스템을 재부팅 후, 이 스크립트를 다시 실행하세요!"
    exit 0
fi

# ---------------- pyenv/venv/dependency 부분 ----------------
echo "pyenv, dependency, venv 등 나머지 자동화 진행..."
echo "pyenv 종속성 설치 중..."
bash dependencies_install.sh

echo "pyenv 설치 및 설정 중..."
bash pyenv_setup.sh

PYTHON_VERSION="3.11.8"
VENV_NAME="my_env"

echo "Python $PYTHON_VERSION 설치 및 가상환경($VENV_NAME) 생성 중..."
pyenv install $PYTHON_VERSION && echo "Python version $PYTHON_VERSION installed."
pyenv shell $PYTHON_VERSION && echo "Python version set to $PYTHON_VERSION."
pyenv virtualenv $PYTHON_VERSION "$VENV_NAME" && echo "Virtual environment '$VENV_NAME' created."
pyenv activate "$VENV_NAME" && echo "Virtual environment '$VENV_NAME' activated."

# === 여기서부터 requirements.txt 설치 추가 ===
REQ_PATH="korean_AU/requirements.txt"
if [ -f "$REQ_PATH" ]; then
    echo "requirements.txt 발견! 패키지 일괄 설치 시작..."
    pip install -r "$REQ_PATH"
else
    echo "requirements.txt 파일이 없습니다! ($REQ_PATH)"
fi

echo "=== 전체 개발환경 설치 완료! ==="
