#!/bin/bash

# Exit script on any error
set -e

# Variables
RUBY_VERSION="3.1.0"
NODE_VERSION="16"
YARN_VERSION="1.22.19"

# Install RVM and Ruby
if ! command -v rbenv &> /dev/null
then
    echo "Installing rbenv..."
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    source ~/.bashrc
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
fi

source ~/.bashrc
rbenv install -s $RUBY_VERSION
rbenv global $RUBY_VERSION

# Install Node.js
if ! command -v node &> /dev/null
then
    echo "Installing Node.js..."
    curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Install Yarn
if ! command -v yarn &> /dev/null
then
    echo "Installing Yarn..."
    npm install -g yarn@$YARN_VERSION
fi

echo "Environment setup complete."