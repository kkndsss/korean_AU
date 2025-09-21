#!/bin/bash
# cuda_install.sh - wrapper to call GPU-specific installer with SKIP_REBOOT passed through
# Usage: ./cuda_install.sh <l4|t4|v100>

set -euo pipefail

GPU_TYPE=${1:-""}

echo "=== GPU 타입별 CUDA 설치 스크립트 ==="
echo "Usage: $0 <l4|t4|v100>"

if [ -z "$GPU_TYPE" ]; then
    echo "오류: GPU 타입 인자가 필요합니다."
    echo "사용법: $0 <l4|t4|v100>"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$GPU_TYPE" in
    l4|L4)
        echo "L4 GPU용 설치를 시작합니다..."
        chmod +x "${SCRIPT_DIR}/cuda_install_l4.sh"
        SKIP_REBOOT=${SKIP_REBOOT:-1} "${SCRIPT_DIR}/cuda_install_l4.sh"
        ;;
    t4|T4)
        echo "T4 GPU용 설치를 시작합니다..."
        chmod +x "${SCRIPT_DIR}/cuda_install_t4.sh"
        SKIP_REBOOT=${SKIP_REBOOT:-1} "${SCRIPT_DIR}/cuda_install_t4.sh"
        ;;
    v100|V100)
        echo "V100 GPU용 설치를 시작합니다..."
        chmod +x "${SCRIPT_DIR}/cuda_install_v100.sh"
        SKIP_REBOOT=${SKIP_REBOOT:-1} "${SCRIPT_DIR}/cuda_install_v100.sh"
        ;;
    *)
        echo "지원되지 않는 GPU 타입입니다: $GPU_TYPE"
        echo "사용법: $0 <l4|t4|v100>"
        exit 1
        ;;
esac

echo "=== 설치 완료 ==="
echo "시스템 재부팅이 필요할 수 있습니다."
echo "재부팅 후 'nvidia-smi' 명령어로 GPU 인식 확인하세요."
