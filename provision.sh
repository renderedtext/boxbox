#!/usr/bin/env bash

set -eou pipefail

cd /tmp

echo "[PROVISIONER] Set up timezone to Belgrade"
sudo rm -rf /etc/localtime
sudo ln -s /usr/share/zoneinfo/Europe/Belgrade /etc/localtime

echo "[PROVISIONER] Adding extra apt repositories"

# postgres
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O- | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" | sudo tee /etc/apt/sources.list.d/postgresql.list

# rabbit
sudo sh -c 'echo "deb https://dl.bintray.com/rabbitmq/debian $(lsb_release -sc) main" >> /etc/apt/sources.list.d/rabbitmq.list'
wget -O- https://dl.bintray.com/rabbitmq/Keys/rabbitmq-release-signing-key.asc | sudo apt-key add -
wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | sudo apt-key add -

# redis
sudo add-apt-repository ppa:chris-lea/redis-server

# elixir
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -

# ruby
sudo apt-get -y install software-properties-common
sudo apt-add-repository ppa:brightbox/ruby-ng

# gcloud
export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "[PROVISIONER] Running apt update" 
sudo apt update

echo "[PROVISIONER] Installing Basic Tools"
sudo apt-get install -y \
  htop \
  git \
  vim \
  tmux \
  zsh \
  curl \
  wget \
  build-essential \
  xauth \
  ack-grep \
  python-pip \
  software-properties-common \
  postgresql-10 \
  rabbitmq-server \
  redis-server \
  esl-erlang \
  elixir \
  nodejs \
  ruby2.5 \
  ruby2.5-dev \
  google-cloud-sdk \
  kubectl \
  silversearcher-ag \
  libpq-dev \
  tree

echo "[PROVISIONER] Installing Docker"
curl -L https://get.docker.com | bash > /dev/null
sudo usermod -aG docker vagrant

echo "[PROVISIONER] Installing Firefox"
wget https://sourceforge.net/projects/ubuntuzilla/files/mozilla/apt/pool/main/f/firefox-mozilla-build/firefox-mozilla-build_56.0.1-0ubuntu1_amd64.deb
sudo dpkg -i firefox-mozilla-build_56.0.1-0ubuntu1_amd64.deb

echo "[PROVISIONER] Setting up zsh"
sudo chsh -s /bin/zsh vagrant

echo "[PROVISIONER] Installing Hub"
wget https://github.com/github/hub/releases/download/v2.5.0/hub-linux-amd64-2.5.0.tgz
tar xvzf hub-linux-amd64-2.5.0.tgz
cd hub-linux-amd64-2.5.0 && sudo chmod +x install && sudo ./install && cd -

echo "[PROVISIONER] Installing Docker Compose"
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "[PROVISIONER] Creating postgres user 'developer' with CREATEDB privilege"
sudo systemctl start postgresql
sudo -u postgres bash -c "psql -c \"CREATE USER developer WITH PASSWORD 'developer';\""
sudo -u postgres bash -c "psql -c \"ALTER USER developer WITH SUPERUSER;\""
sudo -u postgres bash -c "psql -c \"ALTER USER developer CREATEDB;\""

echo "[PROVISIONER] Installing yarn"
sudo npm install -g yarn

echo "[PROVISIONER] Installing ruby"
sudo gem install bundler

echo "[PROVISIONER] Installing awscli"
pip install awscli --upgrade --user
echo "export PATH=~/.local/bin:\$PATH" >> ~/.zshrc
echo "export PATH=~/.local/bin:\$PATH" >> ~/.bashrc

echo "[PROVISIONER] Installing minikube"
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.24.1/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/

echo "[PROVISIONER] Installing golang 1.11"
sudo curl -O https://storage.googleapis.com/golang/go1.11.1.linux-amd64.tar.gz
sudo tar -xf go1.11.1.linux-amd64.tar.gz
sudo mv go /usr/local

echo "[PROVISIONER] Rabbitmq configuration"
sudo systemctl enable rabbitmq-server
sudo systemctl start rabbitmq-server
sudo rabbitmq-plugins enable rabbitmq_management

echo "[PROVISIONER] Install kube helpers"
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
sudo git clone https://github.com/shiroyasha/kubessh.git /opt/kubessh
sudo ln -s /opt/kubessh/kubessh /usr/local/bin/kubessh
wget https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail -o /tmp/kubetail
sudo chmod +x /tmp/kubetail
sudo mv /tmp/kubetail /usr/local/bin/kubetail

echo "[PROVISIONER] Configure protobuf and elixir"
sudo apt-get install -y protobuf-compiler
mix local.hex --force
mix escript.install hex protobuf --force

echo "[PROVISIONER] Cleaning up config permisssions"
sudo chmod -R 777 /home/vagrant/.config

echo "[PROVISIONER] Installing dotfiles"
git clone https://github.com/renderedtext/dotfiles-1 /home/vagrant/dotfiles
cd /home/vagrant/dotfiles && ./install && cd -
echo "source ~/.aliases" >> /home/vagrant/.bashrc
