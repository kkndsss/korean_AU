#!/bin/bash

# pyenv 설치
curl https://pyenv.run | bash && echo "pyenv installed."

# ~/.bashrc 파일에 환경 변수 추가
echo 'export PATH="$HOME/.pyenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc

# 환경 변수 적용

# 변경: don't exec $SHELL inside an automation script — just tell the user to reload shell
echo ".bashrc updated with pyenv variables."
echo "Please run: source ~/.bashrc OR open a new shell to use pyenv in subsequent commands."
# DO NOT exec $SHELL (removes it if present)
# exec $SHELL   <-- remove this line
