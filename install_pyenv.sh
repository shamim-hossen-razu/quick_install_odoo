#!/bin/bash

check_pyenv() {
    if command -v pyenv > /dev/null 2>&1; then
        echo "Pyenv is installed."
    else
        echo "Pyenv is not installed."
        install_pyenv
    fi
}

install_pyenv() {
    echo "Installing Pyenv..."
    Update package manager and install prerequisites
    sudo apt-get update
    sudo apt-get install -y \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        wget \
        curl \
        llvm \
        libncurses5-dev \
        libncursesw5-dev \
        xz-utils \
        tk-dev \
        libffi-dev \
        liblzma-dev \
        python3-openssl \
        git

    # Clone Pyenv repository from GitHub
    git clone https://github.com/pyenv/pyenv.git ~/.pyenv

    # Add Pyenv to the shell environment
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc

    # Reload the shell configuration
    source ~/.bashrc

}

# Call the function to check and install Pyenv
check_pyenv


git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv

export PATH="$HOME/.pyenv/plugins/pyenv-virtualenv/bin:$PATH"
eval "$(pyenv virtualenv-init -)"

