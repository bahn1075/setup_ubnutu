# native.sh
# sudo 패스워드 묻지 않음
```
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER > /dev/null && sudo chmod 440 /etc/sudoers.d/$USER && sudo visudo -c -f /etc/sudoers.d/$USER
```
# sudo no passwd 확인 방법
```
sudo -l  # 현재 사용자의 sudo 권한 목록 확인
sudo cat /etc/sudoers.d/$USER  # 파일 내용 확인
ls -la /etc/sudoers.d/$USER  # 파일 권한 확인 (440이어야 함)
sudo -n true && echo "패스워드 없이 sudo 가능" || echo "패스워드 필요"  # 실제 테스트
```
# 필수설치
```
sudo apt update && sudo apt upgrade -y
```

# install essentials
```
sudo apt install zip gnome-tweaks gh timeshift wget btop zsh curl net-tools fonts-cascadia-code jq vim -y
```
# nord gnome shell theme 설치
```
# 테마 다운로드
cd temp
git clone https://github.com/EliverLara/Nordic.git

# 테마 디렉토리로 복사
mkdir -p ~/.themes
cp -r Nordic ~/.themes/

# 또는 시스템 전체에 설치
sudo cp -r Nordic /usr/share/themes/
```
gnome shell extension (메뉴에서 '확장' 이라고 이름 붙여진)
에서 user theme를 활성화 하고 터미널에서
```
gnome-tweaks
```
수행 후 appearence 에서 shell 부분에 nord 선택

# lunarlake npu driver
https://github.com/intel/linux-npu-driver/releases

# github 로그인
```
gh auth login

git config --global user.name "cozy"
git config --global user.email bahn1075@gmail.com
```
# edge browser install
https://www.microsoft.com/en-us/edge/business/download?form=MA13FJ

여기서 다운로드 받고 다운로드 받은 파일에 우클릭해서 app center(=snap)으로 설치한다.

# ghostty 설치
```
snap install ghostty --classic
```

###################ghostty 설정#########################

ghostty에서 config 설정을 열고 메모장으로 config 파일이 열리면 아래 내용을 붙여넣는다
```
# BEGIN el_init ghostty config
#Nord Theme
theme = Nord

# Clipboard
# 선택한 텍스트를 clipboard로 자동 복사
copy-on-select = clipboard
right-click-action = paste
# END el_init ghostty config
```
###################ghostty 설정#########################

# vs code 설치 
```
sudo snap install code --classic
```

# Meslo nerd font
```
curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.zip -o /tmp/meslo.zip && unzip /tmp/meslo.zip -d /tmp/meslo && sudo mkdir -p /usr/share/fonts/truetype/meslo-nerd && sudo cp /tmp/meslo/*.ttf /usr/share/fonts/truetype/meslo-nerd/ && sudo fc-cache -fv && rm -rf /tmp/meslo*
```

# ohmyzsh
```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
# brew 설치
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
# brew 설정
```
echo >> /home/$USER/.zshrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/$USER/.zshrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

# zsh-syntax-highlighting 설치
```
cd /tmp
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

# .zshrc에 플러그인 추가 (이미 있으면 중복 추가 방지)
```
# plugins 라인이 없으면 추가
if ! grep -q "^plugins=" ~/.zshrc; then
  echo "plugins=(git zsh-syntax-highlighting zsh-autosuggestions)" >> ~/.zshrc
else
  # plugins 라인이 있으면 플러그인 추가 (중복 방지)
  if ! grep -q "zsh-syntax-highlighting" ~/.zshrc; then
    sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-syntax-highlighting)/' ~/.zshrc
  fi
  if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
    sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions)/' ~/.zshrc
  fi
fi
source ~/.zshrc
```

# brew 설치 대상
```
brew install starship fastfetch k9s eza
```

# superfile 설치 (실행 spf)
```
bash -c "$(curl -sLo- https://superfile.dev/install.sh)"
```

# starship 설정 추가
```
curl -o ~/.config/starship.toml https://raw.githubusercontent.com/bahn1075/el_init/ubuntu/starship.toml

echo 'eval "$(starship init zsh)"' >> /home/$USER/.zshrc
```
# fastfetch 설정 추가
```
echo 'fastfetch' >> /home/$USER/.zshrc
source ~/.zshrc
```

# virtual box 설치
```
sudo apt install virtualbox
```

# npm 설치 (oh my logo)
```
sudo apt install npm -y
echo 'npx oh-my-logo "thinkpad!!" sunset --filled' >> ~/.zshrc
source ~/.zshrc
```
# claude-code native 설치
```
curl -fsSL https://claude.ai/install.sh | bash

# PATH 설정 추가
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

# docker
```
# 기존 버전 삭제
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
```
# apt repo 설정
```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```

# Add the repository to Apt sources:
```
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```
# docker 설치
```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
```

# 설치 확인
```
sudo systemctl status docker
```

# docker install post 작업
```
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

# docker 확인
docker ps
```

# kubectl 설치
```
cd /tmp
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

# minikube install
```
cd /tmp
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb
#minikube 확인
minikube version
```

# minikube start
```
minikube config set cpus 8
minikube config set memory 28672
minikube start --addons=metrics-server,metallb --cni=flannel
minikube tunnel
```
# 기동후 amd gpu plugin 수동 설치
```
kubectl create -f https://raw.githubusercontent.com/ROCm/k8s-device-plugin/master/k8s-ds-amdgpu-dp.yaml
```

# kubectx, kubens 설치
```
curl -fsSL https://raw.githubusercontent.com/bahn1075/el_init/oel10/72.kubectx_kubens.sh | bash
```

# freelens 설치
```
sudo snap install freelens --classic
```
# termius-beta 설치
```
sudo snap install termius-beta
```

#######################################################################################################
- Linux Client 링크

https://kcloud.lgcns.com/vmCubeClients/Tilon/linux/Linker-Linux-v8.0.0.2.deb


- 설치 가이드 (현재 설치 방법 간소화 작업 진행 중)

<설치>
일단 홈페이지에서 다운로드 받는 9버전은 mime.sh가 없어서 작동하지 않음
위에 있는 8버전을 주소창에서 직접 다운로드 받고 아래 절차대로 설치


0. 의존성 사전설치
sudo apt update
sudo apt install libqt5websockets5 libqt5websockets5-dev

#또는 더 포괄적으로 Qt5 관련 패키지 설치
sudo apt install qtbase5-dev qt5-qmake libqt5websockets5

1. 다운로드 디렉토리에서 패키지 설치

    - sudo dpkg -i Linker-Linux~~.deb(linker client 파일)

2. 서비스 등록

    - sudo /usr/local/TILON/DstationClient/install.sh

    - /usr/local/TILON/DstationClient/setmime.sh
    => zsh: 그런 파일이나 디렉터리가 없습니다: /usr/local/TILON/DstationClient/setmime.sh
    => 해결책
       8버전 설치 후 파일 내용 확인 하면 아래와 같음
       cat /usr/local/TILON/DstationClient/setmime.sh
        mkdir -p $HOME/.local/share/mime/packages
        cp /usr/local/TILON/DstationClient/dslinker9.xml $HOME/.local/share/mime/packages/dslinker9.xml
        cp /usr/local/TILON/DstationClient/dslinker9.desktop $HOME/.local/share/applications

        xdg-mime default dslinker9.desktop x-scheme-handler/dslinker9
        update-mime-database ~/.local/share/mime
        xdg-mime query default x-scheme-handler/dslinker9
        update-mime-database ~/.local/share/mime

#MIME 타입 핸들러 확인
CURRENT_DEFAULT=$(xdg-mime query default x-scheme-handler/dslinker9)

#결과 출력
echo "현재 x-scheme-handler/dslinker MIME 타입 핸들러: $CURRENT_DEFAULT"


3. 서비스 상태 확인

    - sudo systemctl status Tservice


1. Firefox 실행

2. 주소창에 about:config 입력

3. 경고 수락

4. network.protocol-handler.expose.dslinker9 을 true로 추가

5. 터미널에서 "update-desktop-database ~/.local/share/applications" 명령어로 MIME DB 갱신

6. Firefox 종료

7. 접속 재시도


<설치 후 라이브러리 이슈로 미동작 시 조치 방법>

1. 라이브러리 설치

- sudo apt install libasound2-dev libpulse-dev zlib1g-dev libssl-dev clang-format libkrb5-dev libsystemd-dev libcjson-dev libavcodec-dev libavutil-dev libswresample-dev liburiparser-dev libjson-c-dev libicu-dev libcups2-dev libfuse3-dev libsdl2-dev libcurl4-openssl-dev libsdl2-ttf-dev libusb-1.0-0-dev libswscale-dev libavformat-dev libavutil-dev libavdevice-dev nlohmann-json3-dev
