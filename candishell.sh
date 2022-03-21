#!/bin/bash

BREW="sudo brew install "
APT="sudo apt-get install "
SNAP="sudo snap install "
NPM="sudo npm -g i "

if [[ "$OSTYPE" == "darwin"* ]]; then
  INSTALL=$BREW
  OS="Mac"
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  INSTALL=$APT
  OS="Linux"
fi

install(){
  if ! $($1) --version; then
    $INSTALL $1
  fi
}

#Mac Prereqs
if [[ "$OSTYPE" == "darwin"* ]]; then
  #Homebrew
  if ! brew --version; then
    wget -O ~/install.sh https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh; chmod a+x ~/install.sh; ~/install.sh; rm ~/install.sh
  fi

  #Git
  if ! git --version; then
    $INSTALL git
  fi

  #Node
  if ! node --version; then
    $INSTALL node
  fi

  #NPM
  if ! npm -- version; then
    $INSTALL npm
  fi
then

#Debian/Ubuntu Linux Prereqs
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  #APT
  if ! apt-get update; then
    echo "Requires APT"
    exit 1
  fi

  #Node
  if ! node --version; then
    $INSTALL nodejs
  fi

  #NPM
  if ! npm --version; then
    $NPM npm
  fi

  #Snap
  if ! snap --version; then
    $INSTALL snapd
  fi
fi

#Universal Prereqs - Node Version
NODEVERSION=$(node -v | cut -c2-3)

if [ $((NODEVERSION)) -le 15 ]; then
  if ! n --version; then
    $NPM n
  fi

  sudo n stable

  NODEVERSION=$(node -v | cut -c2-3)
  if [ $((NODEVERSION)) -le 15 ]; then
    echo "You will have to exit the shell and try again."
    exit 0
  fi
fi

git config --global core.autocrlf false
git config --global core.eol lf
rm -rf ~/candishell
git clone https://github.com/CandiceJoy/CandiShell.git ~/candishell

if ! cmp -s ~/candishell.sh ~/candishell/candishell.sh
then
  cp ~/candishell/candishell.sh ~/candishell.sh
  rm -rf ~/candishell
  echo "Script updated; please re-rerun"
  exit 0
fi

#npm --prefix ~/candishell i
#npm --prefix ~/candishell start $1

#Start Script Replacement
install "zsh"
install "exa"
install "dos2unix"
install "tmux"
install "autojump"
install "fzf"
install "tree"
install "curl"
install "iftop"
install "lnav"
install "nnn"

#Reattach to user namespace for Mac - clipboard syncing for tmux
if [[ OS == "Mac" ]] && ! reattach-to-user-namespace --version; then
  $INSTALL reattach-to-user-namespace
fi

#XClip for Linux
if [[ OS == "Linux" ]] && ! xclip --version; then
  $INSTALL xclip
fi

#BTop for Mac
if [[ OS == "Mac" ]] && ! btop --version; then
  $INSTALL btop
fi

#BTop for Linux
if [[ OS == "Linux" ]] && ! btop --version; then
  $SNAP btop
fi

#FKill
if ! fkill --version; then
  $NPM fkill
fi

#RipGrep
if ! rg --version; then
  $INSTALL ripgrep
fi

#Bat for Mac
if [[ OS == "Mac" ]] && ! bat --version; then
  $INSTALL bat
fi

#Bat for Linux
if [[ OS == "Linux" ]] && ! batcat --version; then
  $INSTALL bat
fi

if [[ OS == "Mac" ]] && ! fd --version; then
  $INSTALL fd
fi

if [[ OS == "Linux" ]] && ! fdfind --version; then
  $INSTALL fd-find
fi

#TLDR
if ! tldr --version; then
  $NPM tldr
fi

#Oh My ZSH
if [ ! -d ~/.oh-my-zsh/ ]; then
  wget -O ~/install.sh https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh; chmod a+x ~/install.sh; ~/install.sh --unattended; rm ~/install.sh; sudo chsh -s "/usr/bin/zsh" "$USER"
fi

#ZSH Syntax Highlighting
if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/ ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

#ZSH Autosuggestions
if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/ ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

#Powerline 10k Theme
if [ ! -d ~/.oh-my-zsh/custom/themes/powerlevel10k ]; then
  git clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k
fi

#TMUX Plugin Manager
if [ ! -d ~/.tmux/plugins/tpm/ ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

#ZSHRC
if ! cmp -s ~/.zshrc ~/candishell/.zshrc; then
  cp ~/candishell/.zshrc ~/.zshrc
fi

#TMUX Conf
if ! cmp -s ~/.tmux.conf ~/candishell/.tmux.conf; then
  cp ~/candishell/.tmux.conf ~/.tmux.conf
fi

#P10k Settings
if ! cmp -s ~/.p10k.zsh ~/candishell/.p10k.zsh; then
  cp ~/candishell/.p10k.zsh ~/.p10k.zsh
fi

#Remote Change Script
if ! cmp -s ~/remote.sh ~/candishell/.remote.sh; then
  cp ~/candishell/remote.sh ~/remote.sh
fi

#SSH Config
if ! cmp -s ~/.ssh/config ~/candishell/config; then
  cp ~/candishell/config ~/.ssh/config
fi
#End Script Replacement

rm -rf ~/candishell
echo "Run source ~/.zshrc to update"