#!/bin/bash
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

git config --global core.autocrlf true
git clone https://github.com/CandiceJoy/CandiShell.git ~/candishell
npm --prefix ~/candishell i
npm --prefix ~/candishell start
rm -rf ~/candishell