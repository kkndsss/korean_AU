# Korean_AU 프로젝트

이 프로젝트는 혐오 발언(hate speech) 분류 모델을 학습하고 추론하는 과정을 포함하고 있습니다. 각 모듈의 역할 및 GCP 환경 설정에 대한 설명을 다음과 같이 정리하였습니다.



## 목차
1. [프로젝트 디렉터리 구조](#1-프로젝트-디렉터리-구조)
2. [코드에 대한 설명](#2-코드에-대한-설명)
    - 2.1 [데이터 처리 모듈 (data.py)](#21-데이터-처리-모듈-datapy)
    - 2.2 [모델 모듈 (model.py)](#22-모델-모듈-modelpy)
    - 2.3 [유틸리티 모듈 (utils.py)](#23-유틸리티-모듈-utilspy)
    - 2.4 [메인 모듈 (main.py)](#24-메인-모듈-mainpy)
    - 2.5 [추론 모듈 (inference.py)](#25-추론-모듈-inferencepy)
3. [GCP에서 환경 설정](#3-gcp에서-환경-설정)
    - 3.1 [CUDA 및 NVIDIA 드라이버 설치 (cuda_install.sh)](#31-cuda-및-nvidia-드라이버-설치-cuda_installsh)
    - 3.2 [Pyenv 종속성 설치 (dependencies_install.sh)](#32-pyenv-종속성-설치-dependencies_installsh)
    - 3.3 [Pyenv 설치 및 환경 변수 설정 (pyenv_setup.sh)](#33-pyenv-설치-및-환경-변수-설정-pyenv_setupsh)
    - 3.4 [Python 및 가상 환경 설정 (python_virtualenv.sh)](#34-python-및-가상-환경-설정-python_virtualenvsh)
    - 3.5 [Git 리포지토리 클론 (clone_git_repo.sh)](#35-git-리포지토리-클론-clone_git_reposh)
    - 3.6 [전체 스크립트 실행 (full_install.sh)](#36-전체-스크립트-실행-full_installsh)
    - 3.7 [Makefile로 간편 실행](#37-makefile로-간편-실행)

---

## 1. 프로젝트 코드 구조
```plaintext
Korean_AU/
├── README.md                             # 프로젝트 설명 파일
├── LICENSE                               # 라이선스 파일
├── NIKL_AU_2023_COMPETITION_v1.0/        # 데이터셋 폴더
│   ├── dev.csv
│   ├── test.csv
│   └── train.csv
├── Jupyter Notebook/                     # 데이터 전처리 Jupyter Notebook
│   └── preprocessing.ipynb
├── model/                                # 모델 체크포인트 및 결과 파일 폴더
│   └── results
├── requirements.txt                      # 필요한 라이브러리 목록
├── sh_for_gcp/                           # GCP 환경 설정 쉘 스크립트 폴더
│   ├── clone_git_repo.sh
│   ├── cuda_install.sh
│   ├── dependencies_install.sh
│   ├── full_install.sh
│   ├── pyenv_setup.sh
│   └── python_virtualenv.sh
├── src/                                  # 소스 코드 폴더
│   ├── data.py
│   ├── inference.py
│   ├── main.py
│   ├── model.py
│   └── utils.py
└── wandb/                                # Weights and Biases 훈련 로그 폴더
    └── [다양한 실험 로그 파일들]                              # 유틸리티 모듈
```

주의 및 가이드

- NIKL 데이터 다운로드: `NIKL_AU_2023_COMPETITION_v1.0/` 폴더의 데이터(dev.csv, test.csv, train.csv)는 국립국어원(NIKL)에서 별도로 다운로드해야 합니다. 저작권 및 이용 약관을 준수해야 하며, 원본/가공본의 GitHub 업로드는 지양합니다. 이 저장소에는 폴더만 비워둡니다.
- 데이터 전처리 노트북: `Jupyter Notebook/` 폴더에는 사용자가 직접 데이터 정제를 위한 노트북(예: `preprocessing.ipynb`)을 생성하여 사용하십시오. 데이터 파일은 로컬/개인 스토리지에 보관하고, 공용 저장소로의 업로드를 피하십시오.

## 2. 코드에 대한 설명

### 2.1 데이터 처리 모듈 (data.py)

데이터를 준비하고 처리하는 모듈입니다. 주요 클래스 및 함수는 다음과 같습니다:

- **hate_dataset class**  
  토크나이징된 입력을 받아 데이터셋 클래스로 반환하는 역할을 합니다.

- **load_data**  
  CSV 파일로부터 데이터를 읽어와서 데이터프레임으로 반환하는 함수입니다.

- **construct_tokenized_dataset**  
  데이터프레임을 입력으로 받아 토크나이징한 후 반환하는 함수입니다.

- **prepare_dataset**  
  CSV 파일로부터 데이터를 읽어와서 토크나이징된 데이터셋으로 반환하는 함수입니다.

### 2.2 모델 모듈 (model.py)

모델 및 토크나이저를 관리하고 학습을 진행하는 모듈입니다:

- **load_tokenizer_and_model_for_train**  
  Hugging Face로부터 사전학습된 토크나이저와 모델을 불러와 반환하는 함수입니다. 이때, `config.num_labels`를 2로 수정합니다.

- **load_model_for_inference**  
  모델과 토크나이저를 반환하는 함수로, 학습된 모델 체크포인트로부터 불러옵니다.

- **load_trainer_for_train**  
  모델과 데이터셋을 입력으로 받아 `Trainer`를 반환하는 함수입니다.

- **train**  
  모델, 토크나이저, 데이터셋을 받아와 `Trainer`를 통해 학습을 진행하고, 최종적으로 최상의 모델을 저장하는 함수입니다.

### 2.3 유틸리티 모듈 (utils.py)

여러 작업에 도움이 되는 유틸리티 함수들이 포함되어 있습니다:

- **compute_metrics**  
  `Trainer`에서 메트릭을 계산하기 위해 사용되는 함수입니다.

### 2.4 메인 모듈 (main.py)

모델 학습 및 추론에 필요한 설정(config)을 관리합니다:

- **parse_args**  
  모델 학습 및 추론에 쓰일 설정(config)을 관리하는 함수입니다.

### 2.5 추론 모듈 (inference.py)

학습된 모델을 통해 결과를 추론하는 기능을 담당합니다:

- **inference**  
  학습된(trained) 모델을 통해 결과를 추론하는 함수입니다.

- **infer_and_eval**  
  학습된 모델로 추론을 진행하고, 예측한 결과를 반환하는 함수입니다.

---

## 3. GCP에서 환경 설정

이 섹션에서는 GCP VM 환경에서 CUDA 설치 및 pyenv 설정 등 필요한 환경을 자동으로 구성하기 위한 쉘 스크립트를 설명합니다.

### 빠른 시작: Step-by-Step 가이드

아래 단계는 저장소를 클론하는 것부터 GPU 타입을 선택하여 CUDA/드라이버를 설치하고, 재부팅 후 전체 설치를 진행하는 흐름입니다.

1) 저장소 클론 및 디렉터리 이동
```bash
git clone https://github.com/jonhyuk0922/korean_AU.git
cd korean_AU/sh_for_gcp
```

2) (선택) Ubuntu 버전 확인 — 22.04(Jammy) 권장
```bash
make check-ubuntu
```

3) CUDA 및 NVIDIA 드라이버 설치 — GPU 타입 지정 필수
```bash
# GPU 타입은 l4 | t4 | v100 중 하나를 선택하세요.
make cuda GPU=l4
# 또는 직접 스크립트 실행
bash cuda_install.sh l4
```

4) 재부팅 후 재로그인하여 확인
```bash
nvidia-smi
/usr/local/cuda-12.2/bin/nvcc --version
```

5) 전체 설치 플로우 실행 (pyenv, venv, 의존성 설치 등)
```bash
# 저장소 루트에서 실행했다면 sh_for_gcp로 이동
cd korean_AU/sh_for_gcp

# Makefile로 실행
make full-install GPU=l4

# 또는 스크립트로 직접 실행 (리포지토리 URL 필요 시)
GIT_REPO_URL="https://github.com/your/repository.git" bash full_install.sh l4
```

6) 가상환경 활성화 후 프로젝트 사용
```bash
# 예시: pyenv로 생성된 가상환경 이름이 my_env인 경우
pyenv activate my_env
python --version
```

### 3.1 CUDA 및 NVIDIA 드라이버 설치 (`cuda_install.sh`)

- **기능**: CUDA 12.2 및 NVIDIA 드라이버를 설치합니다.
- **드라이버 정책**: NVIDIA 550-server 계열로 통일하며, 관련 유틸 패키지를 함께 설치합니다.
  - 설치 패키지: `nvidia-driver-550-server`, `nvidia-utils-550-server`, `nvidia-compute-utils-550-server`, `libnvidia-compute-550-server`, `libnvidia-decode-550-server`, `libnvidia-encode-550-server`, `libnvidia-fbc1-550-server`
- **GPU 타입 인자 필수**: 자동 감지를 제거했습니다. 아래 중 하나를 인자로 전달해야 합니다: `l4`, `t4`, `v100`.
- **사용법**:
    ```bash
    # 예시: L4 GPU 환경
    bash sh_for_gcp/cuda_install.sh l4

    # 예시: T4 GPU 환경
    bash sh_for_gcp/cuda_install.sh t4

    # 예시: V100 GPU 환경
    bash sh_for_gcp/cuda_install.sh v100
    ```
- **주의사항**: 설치 후 시스템 재부팅이 필요할 수 있습니다. 재부팅 후 `nvidia-smi`로 확인하세요.
  - 스크립트에서 설치 완료 후 `sudo reboot`를 수행합니다. 재부팅 후 `nvidia-smi`와 `nvcc --version`으로 확인하십시오.

### 3.2 Pyenv 종속성 설치 (`dependencies_install.sh`)

- **기능**: `pyenv` 설치에 필요한 종속성들을 설치합니다.
- **설치 항목**: `make`, `build-essential`, `libssl-dev` 등 다양한 패키지들이 포함됩니다.

### 3.3 Pyenv 설치 및 환경 변수 설정 (`pyenv_setup.sh`)

- **기능**: `pyenv`를 설치하고, 환경 변수 설정을 추가합니다.
- **환경 파일 수정**: `~/.bashrc` 파일에 `pyenv` 관련 설정을 추가합니다.

### 3.4 Python 및 가상 환경 설정 (`python_virtualenv.sh`)

- **기능**: Python 버전 3.11.8을 설치하고, 가상환경을 생성하고 활성화합니다.
- **가상환경 이름**: 기본적으로 `"my_env"`라는 이름으로 생성됩니다.

### 3.5 Git 리포지토리 클론 (`clone_git_repo.sh`)

- **기능**: curl, git, vim 등을 설치한 후, 환경 변수로 제공된 Git 리포지토리 URL을 사용해 리포지토리를 클론합니다.
- **환경 변수 사용**: 스크립트를 실행할 때 `GIT_REPO_URL` 환경 변수를 설정해주어야 합니다.

### 3.6 전체 스크립트 실행 (`full_install.sh`)

- **기능**: 위의 모든 쉘 스크립트를 순차적으로 실행하여 전체 환경을 설정합니다.
- **Ubuntu 22.04 안내**: 스크립트는 Ubuntu 22.04 (Jammy) 기준으로 검증되었습니다. 다른 버전에서는 실패할 수 있습니다.
- **사용법**: GPU 타입 인자와 Git 리포지토리 URL을 함께 전달해 실행합니다.
    ```bash
    # L4 GPU 기준 전체 설치 예시
    cd sh_for_gcp
    GIT_REPO_URL="https://github.com/your/repository.git" bash full_install.sh l4
    ```

### 3.7 Makefile로 간편 실행

`sh_for_gcp/Makefile`을 통해 주요 스크립트를 간편하게 실행할 수 있습니다.

- **도움말**
    ```bash
    cd sh_for_gcp
    make help
    ```
- **CUDA/드라이버 설치** (CUDA 12.2, 550-server 계열+유틸 포함)
    ```bash
    # GPU 타입 지정 필수: l4 | t4 | v100
    make cuda GPU=l4
    # 또는 단축 타깃
    make l4
    make t4
    make v100
    ```
- **전체 설치 플로우 실행**
    ```bash
    # GPU 타입 지정 필수 (Ubuntu 22.04 권장)
    make full-install GPU=l4
    ```
- **환경 준비**
    ```bash
    make check-ubuntu   # Ubuntu 22.04 권장 여부 확인
    make deps           # pyenv 종속 패키지 설치
    make pyenv          # pyenv 설치/설정
    make venv           # Python 가상환경 생성/활성화
    ```

---

## GitHub 링크

이 프로젝트의 전체 코드는 GitHub에서 확인할 수 있습니다. 각 쉘 파일과 Python 스크립트의 최신 버전은 [GitHub Repository](https://github.com/jonhyuk0922/korean_AU.git)에 업로드되어 있습니다. 자세한 내용은 해당 링크를 참조하세요.
