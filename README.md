## Install required packages

### Debian
    sudo apt update && sudo apt full-upgrade -y && sudo apt install -y gcc g++ make python3 python3-dev python3-pip python3-setuptools curl git fish neovim thefuck grc

## Install Oh My fish
    curl -L https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish

## Change default shell to fish
    sudo usermod -s /usr/bin/fish username

## Install nvm
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

## Install powerline font
https://github.com/powerline/fonts

## Install omf plugins
    omf install budspencer nvm grc bang-bang fuck expand

## Change budspencer colors
    set budspencer_colors 000000 333333 666666 ffffff 2ea4c9 ff0000 ff0000 ff66ff 3300ff ffffff 00ffff 00ff00

## Update omf.fish file
    echo "" >> ~/.config/fish/conf.d/omf.fish
    echo "# Custom" >> ~/.config/fish/conf.d/omf.fish
    echo "set fish_prompt_pwd_dir_length 0" >> ~/.config/fish/conf.d/omf.fish
    echo "fish_vi_key_bindings" >> ~/.config/fish/conf.d/omf.fish
    echo "alias cls='clear'" >> ~/.config/fish/conf.d/omf.fish
    echo "alias ll='ls -la'" >> ~/.config/fish/conf.d/omf.fish

## All commands
    sudo apt update && sudo apt full-upgrade -y && sudo apt install -y gcc g++ make python3 python3-dev python3-pip python3-setuptools curl git fish neovim thefuck grc
    curl -L https://get.oh-my.fish | fish
    sudo usermod -s /usr/bin/fish pi
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
    omf install budspencer nvm grc bang-bang fuck expand
    echo "" >> ~/.config/fish/conf.d/omf.fish
    echo "#custom" >> ~/.config/fish/conf.d/omf.fish
    echo "set fish_prompt_pwd_dir_length 0" >> ~/.config/fish/conf.d/omf.fish
    echo "fish_vi_key_bindings" >> ~/.config/fish/conf.d/omf.fish
    echo "alias cls='clear'" >> ~/.config/fish/conf.d/omf.fish
    echo "alias ll='ls -la'" >> ~/.config/fish/conf.d/omf.fish
    set budspencer_colors 000000 333333 666666 ffffff 2ea4c9 ff0000 ff0000 ff66ff 3300ff ffffff 00ffff 00ff00
