#!/usr/bin/env bash
# run_full_install_ui_no_git.sh
# 간단 UI: 깃허브 묻지 않음. (소스는 이미 내려받았다고 가정)
set -euo pipefail

echo "=============================================="
echo "간단 설치 UI (Git URL 묻지 않음) — 이미 소스가 내려받아졌다고 가정"
echo "=============================================="
echo

# 1) 가상환경 이름 묻기 (default my_env)
read -r -p '2."너가 생성할 파이썬 가상환경 이름 넣어라" (기본: my_env) : ' VENV_NAME_INPUT
VENV_NAME="${VENV_NAME_INPUT:-my_env}"
echo "가상환경 이름: $VENV_NAME"
echo

# 2) CUDA 선택 (번호로)
echo '3."다음 선택지에서 cuda 선택하고 번호 입력해라.'
echo "   1)T4"
echo "   2)L4"
echo "   3)V100"
read -r -p "번호 입력 (1/2/3): " gpu_choice

case "$gpu_choice" in
  1) GPU_TYPE="t4" ;;
  2) GPU_TYPE="l4" ;;
  3) GPU_TYPE="v100" ;;
  *) echo "잘못된 선택입니다. 기본 T4로 진행합니다."; GPU_TYPE="t4" ;;
esac

echo "선택된 GPU: $GPU_TYPE"
echo

# 3) 최종 확인
read -r -p '4."이대로 한큐에 설치할거지? cuda 설치 후 재부팅되면 알아서 설치된다 걱정마라" (y/N) : ' confirm
confirm=${confirm:-N}
if [[ ! "$confirm" =~ ^[Yy] ]]; then
  echo "설치 취소됨. 스크립트 종료."
  exit 0
fi

# Run installer (assumes full_install_one.sh exists in current dir or project dir)
if [ ! -f "./full_install_one.sh" ]; then
  echo "오류: 현재 디렉터리에 full_install_one.sh가 없습니다. 스크립트 위치로 이동하세요."
  exit 1
fi

# Export VENV_NAME for downstream scripts
export VENV_NAME
export PY_VER="${PY_VER:-3.11.8}"

echo "설치 스크립트 실행: sudo bash ./full_install_one.sh ${GPU_TYPE}"
read -r -p "계속 실행? (y/N): " final_confirm
final_confirm=${final_confirm:-N}
if [[ ! "$final_confirm" =~ ^[Yy] ]]; then
  echo "취소됨."
  exit 0
fi

sudo bash ./full_install_one.sh "${GPU_TYPE}"
