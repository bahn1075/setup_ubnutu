# native.sh
# sudo 패스워드 묻지 않음
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER

#필수설치
sudo apt update && sudo apt upgrade -y

# install essentials
sudo apt install zip timeshift wget btop zsh curl net-tools fonts-cascadia-code jq vim -y

# Meslo nerd font
curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.zip -o /tmp/meslo.zip && unzip /tmp/meslo.zip -d /tmp/meslo && sudo mkdir -p /usr/share/fonts/truetype/meslo-nerd && sudo cp /tmp/meslo/*.ttf /usr/share/fonts/truetype/meslo-nerd/ && sudo fc-cache -fv && rm -rf /tmp/meslo*

#ohmyzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#brew 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#brew 설정
echo >> /home/$USER/.zshrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/$USER/.zshrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    
# zsh-syntax-highlighting 설치
cd /tmp
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# .zshrc에 플러그인 추가 (이미 있으면 중복 추가 방지)
if ! grep -q "zsh-syntax-highlighting" ~/.zshrc; then
  sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-syntax-highlighting)/' ~/.zshrc
  # 만약 plugins= 라인이 없다면 추가
  if ! grep -q "^plugins=" ~/.zshrc; then
    echo "plugins=(git kubectl kube-ps1 zsh-syntax-highlighting zsh-autosuggestions)" >> ~/.zshrc
  fi
  # 플러그인 활성화 코드가 없으면 추가
  echo "source \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
fi
source ~/.zshrc
# starship 설정
brew install starship fastfetch k9s

# ghostty 설치
snap install ghostty --classic

###################ghostty 설정#########################
# Append Ghostty configuration to ~/.config/ghostty in an idempotent way
GHOSTTY_CONFIG_DIR="$HOME/.config"
GHOSTTY_CONFIG_FILE="$GHOSTTY_CONFIG_DIR/ghostty"

# Ensure config directory exists
mkdir -p "$GHOSTTY_CONFIG_DIR"

# Only append the block once to avoid duplicates
if ! grep -q "# BEGIN el_init ghostty config" "$GHOSTTY_CONFIG_FILE" 2>/dev/null; then
  cat >> "$GHOSTTY_CONFIG_FILE" <<'GHOSTTY_CONF'
# BEGIN el_init ghostty config
# Nord Theme
theme = Nord

# Clipboard
# 선택한 텍스트를 clipboard로 자동 복사
copy-on-select = clipboard
right-click-action = paste
# END el_init ghostty config
GHOSTTY_CONF
  echo "Appended ghostty config to $GHOSTTY_CONFIG_FILE"
else
  echo "ghostty config already present in $GHOSTTY_CONFIG_FILE (skipping append)"
fi
###################ghostty 설정#########################

# starship 설정 추가
curl -o ~/.config/starship.toml https://raw.githubusercontent.com/bahn1075/el_init/ubuntu/starship.toml

echo 'eval "$(starship init zsh)"' >> /home/$USER/.zshrc

# fastfetch 설정 추가
echo 'fastfetch' >> /home/$USER/.zshrc

source ~/.zshrc

#amd gpu rocm installation
sudo apt update
cd /tmp
wget https://repo.radeon.com/amdgpu-install/7.1/ubuntu/noble/amdgpu-install_7.1.70100-1_all.deb
sudo apt install ./amdgpu-install_7.1.70100-1_all.deb
sudo amdgpu-install -y --usecase=graphics,rocm
sudo usermod -a -G render,video $LOGNAME

# (위에 이어서) amd gpu driver install
sudo apt install "linux-headers-$(uname -r)" "linux-modules-extra-$(uname -r)"
sudo apt install amdgpu-dkms

# npm 설치
sudo apt install npm -y

# docker
# 기존 버전 삭제
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# apt repo 설정
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# docker 설치
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# 설치 확인
sudo systemctl status docker

# post 작업
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

# docker 확인
docker ps

# kubectl 설치
cd /tmp
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# minikube install
cd /tmp
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb
#minikube 확인
minikube version

# minikube start
minikube config set cpus 8
minikube config set memory 28672
minikube start --addons=metrics-server,metallb --cni=flannel
minikube tunnel

#기동후 amd gpu plugin 수동 설치
kubectl create -f https://raw.githubusercontent.com/ROCm/k8s-device-plugin/master/k8s-ds-amdgpu-dp.yaml

# kubectx, kubens 설치
curl -fsSL https://raw.githubusercontent.com/bahn1075/el_init/oel10/72.kubectx_kubens.sh | bash

# freelens 설치
sudo snap install freelens --classic

# vscode 설치
sudo snap install --classic code

# termius-beta 설치
sudo snap install termius-beta

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

# 또는 더 포괄적으로 Qt5 관련 패키지 설치
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

# MIME 타입 핸들러 확인
CURRENT_DEFAULT=$(xdg-mime query default x-scheme-handler/dslinker9)

# 결과 출력
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
