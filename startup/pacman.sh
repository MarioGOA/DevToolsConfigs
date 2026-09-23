#! /usr/bin/bash

echo "Start UP Process Using PacMan"

sudo pacman -S zsh
sudo pacman -S which
sudo pacman -S gcc
sudo pacman -S wofi
sudo pacman -S waybar
sudo pacman -S hyprlock
sudo pacman -S hyprpolkitagent
sudo pacman -S otf-font-awesome
sudo pacman -S ttf-jetbrains-mono-nerd
sudo pacman -S python-pip

if [ $? -ne 0]; then
  echo "-- Process Failed --"
  exit 1
fi

echo "Setting ZSH as terminal"
sudo chsh -s $(which zsh)

install_ohmyzsh() {
  echo "Installing Oh My Zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_power10() {
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
  echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
}

read -p "Install OhMyZsh(y/n)?" choice
case "$choice" in
y | Y) install_ohmyzsh ;;
esac

read -p "Install PowerLevel10K(y/n)?" choice
case "$choice" in
y | Y) install_power10 ;;
esac

echo "Installing Neovim"
sudo pacman -S neovim
