#!/bin/bash

RESET="\e[0m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
GREEN="\e[32m"
MAGENTA="\e[35m"
CYAN="\e[36m"

while [[ $# -gt 0 ]]; do
  case $1 in
    noupdate)
      NOUPDATE=true
      echo -e "${YELLOW}noupdate detected; will not update script${RESET}"
      ;;
    force)
      FORCE=true
      echo -e "${YELLOW}force detected; will overwrite all configs${RESET}"
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
  shift
done

git config --global core.autocrlf false
git config --global core.eol lf
rm -rf $HOME/candishell
git clone https://github.com/CandiceJoy/CandiShell.git $HOME/candishell

if [ ! "$NOUPDATE" ]; then
  if ! cmp -s $HOME/candishell.sh $HOME/candishell/candishell.sh
  then
    cp $HOME/candishell/candishell.sh $HOME/candishell.sh
    rm -rf $HOME/candishell
    echo -e "${CYAN}Script updated; please re-rerun${RESET}"
    exit 0
  fi
fi

BREW="brew install"
APT="sudo apt install"
SNAP="sudo snap install"
NPM="sudo npm -g i"

if [[ "$OSTYPE" == "darwin"* ]]; then
  INSTALL=$BREW
  OS="Mac"
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  INSTALL=$APT
  OS="Linux"
fi

checkcommand() {
  command="$1"

  if command -v "$1"; then
    return 0;
  else
    return 1;
  fi
}

install(){
  name="$1"
  check="$2"

  if [ "$3" ]; then
    installcommand="$3"
  else
    installcommand="$INSTALL $check"
  fi

  echo -e "${BLUE}Checking $name${RESET}"

  if ! checkcommand "$check"; then
    echo -e "${YELLOW}Missing; Installing${RESET}"
    echo $installcommand
    eval "$installcommand"
  if ! checkcommand "$check"; then
      echo -e "${RED}Installation failed${RESET}"
      exit 1
    fi
  else
    echo -e "${GREEN}Found${RESET}"
  fi
}

update(){
  name="$1"
  src="$HOME/candishell/$2"

  if [ ! "$3" ]; then
    dest="$HOME/$2"
  else
    dest="$HOME/$3"
  fi

  if [ "$4" ]; then
    dontoverwrite=true
  else
    unset dontoverwrite
  fi

  echo -e "${BLUE}Checking $name${RESET}"

  if ! cmp -s "$src" "$dest"; then
    if [ ! "$dontoverwrite" ] || [ "$FORCE" ]; then
      echo -e "${YELLOW}updating${RESET}"
      runme="cp $src $dest"
      eval "$runme"
    else
      echo -e "${YELLOW}Skipping${RESET}"
    fi
  else
    echo -e "${GREEN}Already latest version${RESET}"
  fi
}

installnoexec(){
  name="$1"
  check="$HOME/$2"
  installnoexeccommand="$3"

  echo -e "${BLUE}Checking $name${RESET}"

  if [ ! -d $check ]; then
    echo -e "${YELLOW}Missing; Installing${RESET}"
    eval "$installnoexeccommand"
  else
    echo -e "${GREEN}Found${RESET}"
  fi
}

#Mac Prereqs
if [[ "$OSTYPE" == "darwin"* ]]; then
  install "Homebrew" "brew" "/bin/bash -c \"curl -fsSLO https://raw.githubusercontent.com/Homebrew/install/master/install.sh; chmod +x install.sh; ./install.sh\""
  install "WGet" "wget"
  install "Git - Mac" "git"
  install "NodeJS - Mac" "node"
  install "NPM - Mac" "npm"
fi

#Debian/Ubuntu Linux Prereqs
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  #APT
  if ! command -v apt; then
    echo -e "${MAGENTA}Requires APT${RESET}"
    exit 1
  else
    echo -e "${GREEN}APT Found; continuing${RESET}"
  fi

  install "NodeJS - Linux" "node" "$INSTALL nodejs"
  install "NPM - Linux" "npm"

  if [ -f /home/linuxbrew/.linuxbrew/bin/brew ] && ! checkcommand "brew"; then
    echo -e "${YELLOW}Brew installed but not in path; manually setting it up for this shell${RESET}"
    PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
    BREW="/home/linuxbrew/.linuxbrew/bin/brew install"
    #PATH=$(npm bin -g):$PATH
  else
    if [ ! command -v brew ]; then
      wget -O $HOME/install.sh https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh; chmod a+x $HOME/install.sh; $HOME/install.sh; rm $HOME/install.sh
    fi

    if [ -f /home/linuxbrew ] && [ ! ls /home/linuxbrew ]; then
      sudo groupadd brew; sudo chgrp -R brew /home/linuxbrew; sudo chmod 754 /home/linuxbrew; sudo usermod -a -G brew $USER
    fi

    if [ ! -f /home/linuxbrew ]; then
      NOBREW=true
    fi
  fi

fi

install "N" "n" "$NPM n"

#Universal Prereqs - Node Version
NODEVERSION=$(node -v | cut -c2-3)

if [ $((NODEVERSION)) -le 15 ]; then
  sudo n stable

  NODEVERSION=$(node -v | cut -c2-3)
  if [ $((NODEVERSION)) -le 15 ]; then
    echo -e "${CYAN}You will have to exit the shell and try again.${RESET}"
    exit 0
  else
    echo -e "${GREEN}Node version good; continuing${RESET}"
  fi
fi

if [[ $OS == "Mac" ]]; then
  install "Reattach to User Namespace - Mac" "reattach-to-user-namespace"
  install "BTop - Mac" "btop"
  install "Bat - Mac" "bat"
  install "FD - Mac" "fd"
  install "RipGrep - Mac" "rg" "$INSTALL ripgrep"
fi

if [[ $OS == "Linux" ]]; then
  install "XClip - Linux" "xclip"
  install "BTop - Linux" "btop" "$BREW btop"
  install "FD - Linux" "fdfind" "$INSTALL fd-find"
  install "RipGrep - Linux" "rg" "sudo apt install -o Dpkg::Options::=\"--force-overwrite\" bat ripgrep"
  install "Bat - Linux" "batcat" "sudo apt install -o Dpkg::Options::=\"--force-overwrite\" bat ripgrep"
fi

install "ZSH" "zsh"

if [ ! "$NOBREW" ]; then
  install "Exa" "exa" "$BREW exa"
fi

install "Dos2Unix" "dos2unix"
install "TMUX" "tmux"
install "AutoJump" "autojump"
install "FZF" "fzf"
install "Tree" "tree"
install "cURL" "curl"
install "IFTop" "iftop"
install "LNav" "lnav"
install "NNN" "nnn"
install "FKill" "fkill" "$NPM fkill-cli"
install "TLDR" "tldr" "$NPM tldr"
ZSHPATH=$(command -v zsh)
installnoexec "Oh My ZSH" ".oh-my-zsh" "wget -O ~/install.sh https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh; chmod a+x ~/install.sh; ~/install.sh --unattended; rm ~/install.sh; sudo chsh -s \"$ZSHPATH\" \"$USER\""
installnoexec "ZSH Syntax Highlighting" ".oh-my-zsh/custom/plugins/zsh-syntax-highlighting" "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
installnoexec "ZSH Autosuggestions" ".oh-my-zsh/custom/plugins/zsh-autosuggestions" "git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
installnoexec "Powerline 10k Theme" ".oh-my-zsh/custom/themes/powerlevel10k" "git clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k"
installnoexec "TMUX Plugin Manager" ".tmux/plugins/tpm" "git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
update "ZSH Config" ".zshrc"
update "TMUX Config" ".tmux.conf"
update "P10K Settings" ".p10k.zsh" ".p10k.zsh" "true"
update "Remote Change Script" "remote.sh"
update "SSH Config" "config" ".ssh/config"

rm -rf $HOME/candishell
echo -e "${CYAN}Run source ~/.zshrc to update${RESET}"
