#!/bin/bash
wget -O ~/candishell-new.sh https://cdn.jsdelivr.net/gh/CandiceJoy/CandiShell/candishell.sh

if [ ! cmp -s ~/candishell.sh ~/candishell-new.sh ]; then
   cp ~/candishell-new.sh ~/candishell.sh
   rm ~/candishell-new.sh
   echo "Script updated; please re-rerun"
   exit 0
fi

rm ~/candishell-new.sh


wget -O ~/.zshrc https://cdn.jsdelivr.net/gh/CandiceJoy/CandiShell/.zshrc
wget -O ~/.tmux.conf https://cdn.jsdelivr.net/gh/CandiceJoy/CandiShell/.tmux.conf

if [ $1 -eq "update" ]; then
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

git config --global core.autocrlf false
git config --global core.eol lf
git clone https://github.com/CandiceJoy/CandiShell.git ~/candishell
npm --prefix ~/candishell i
npm --prefix ~/candishell start
rm -rf ~/candishell