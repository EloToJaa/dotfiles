#!/bin/bash

result () {
    word=$(echo "$1" | awk '{print tolower($0)}')

    if [ "$word" = "y" -o "$word" = "t" -o "$word" = "yes" -o "$word" = "true" -o "$word" = "tak" ]; then
        return 1
    fi

    return 0
}

echo "Updating packages"
apt update -y

read -p "Do you want to upgrade (Y/N)? " ans
result "$ans"
if [ $? -eq 1 ]; then
    apt full-upgrade -y
fi

read -p "Do you want to install git and curl (Y/N)? " ans
result "$ans"
if [ $? -eq 1 ]; then
    apt install -y curl git
fi

read -p "Do you want to install C compilers (Y/N)? " ans
result "$ans"
if [ $? -eq 1 ]; then
    apt install -y gcc g++ make
fi

read -p "Do you want to install Python (Y/N)? " ans
result "$ans"
if [ $? -eq 1 ]; then
    apt install -y python3 python3-dev python3-pip python3-setuptools
fi

read -p "Do you want to install Vim (Y/N)? " ans
result "$ans"
if [ $? -eq 1 ]; then
    apt install -y neovim
fi

read -p "Do you want to install Fish (Y/N)? " ans
result "$ans"
if [ $? -eq 1 ]; then
    apt install -y fish thefuck grc
    curl -L https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | bash
    omf install budspencer nvm grc bang-bang fuck expand
    set budspencer_colors 000000 333333 666666 ffffff 2ea4c9 ff0000 ff0000 ff66ff 3300ff ffffff 00ffff 00ff00
    echo "" >> ~/.config/fish/conf.d/omf.fish
    echo "# Custom" >> ~/.config/fish/conf.d/omf.fish
    echo "set fish_prompt_pwd_dir_length 0" >> ~/.config/fish/conf.d/omf.fish
    echo "fish_vi_key_bindings" >> ~/.config/fish/conf.d/omf.fish
    echo "alias cls='clear'" >> ~/.config/fish/conf.d/omf.fish
    echo "alias ll='ls -la'" >> ~/.config/fish/conf.d/omf.fish
    sudo usermod -s /usr/bin/fish $(whoami)
fi
