#wsl용 init 파일
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

# starship 설정 추가
curl -o ~/.config/starship.toml https://raw.githubusercontent.com/bahn1075/el_init/ubuntu/starship.toml

echo 'eval "$(starship init zsh)"' >> /home/$USER/.zshrc

# fastfetch 설정 추가
echo 'fastfetch' >> /home/$USER/.zshrc

source ~/.zshrc

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
minikube config set cpus 4
minikube config set memory 28672
minikube start --addons=metrics-server,ingress,ingress-dns,logviewer,metallb

# kubectx, kubens 설치
curl -fsSL https://raw.githubusercontent.com/bahn1075/el_init/oel10/72.kubectx_kubens.sh | bash