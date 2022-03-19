#!/bin/bash
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

if [ "$1" = "update" ]; then
  wget -O ~/.zshrc https://cdn.jsdelivr.net/gh/CandiceJoy/CandiShell/.zshrc
  wget -O ~/.tmux.conf https://cdn.jsdelivr.net/gh/CandiceJoy/CandiShell/.tmux.conf
  rm -rf ~/candishell
  exit 0
fi

if [ ! -f /usr/bin/node ]; then
  sudo apt-get install nodejs
fi

if [ ! -f /usr/bin/npm ]; then
  sudo npm install -g npm
fi

NODEVERSION=$(node -v | cut -c2-3)

if [ $((NODEVERSION)) -le 15 ]; then
  if [ ! -f /usr/local/bin/n ]; then
    sudo npm install -g n
  fi

  sudo n stable

  NODEVERSION=$(node -v | cut -c2-3)
  if [ $((NODEVERSION)) -le 15 ]; then
    echo "You will have to exit and try again."
    exit 0
  fi
fi

npm --prefix ~/candishell i
npm --prefix ~/candishell start $1
rm -rf ~/candishell
source ~/.zshrc