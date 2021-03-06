# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
#ARCH=$(arch)

#if [[ $ARCH == "arm64" ]] && [[ $ROSETTA == true ]]; then
#	arch -x86_64 zsh
#fi

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
if [ -d $HOME/bin ]; then
  export PATH=$HOME/bin:$PATH
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export ZSH_TMUX_TERM="tmux-256color"
export ZSH_TMUX_UNICODE="true"
export TERM="xterm-256color"
export COLORTERM="truecolor"
export TNS_ADMIN="/Users/candice/tns-admin"
export GPG_KEY_ID="D51ABC8A5F5828DA"
export GPG_TTY="$TTY"

if [ -f /home/linuxbrew/.linuxbrew/bin/brew ] && ! command -v brew; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if [ -e ~/.zshrc.local ]; then
	source ~/.zshrc.local
fi

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-interactive-cd lpass autojump colored-man-pages colorize command-not-found emacs nanoc pm2 safe-paste screen tmux)

export ZSH_TMUX_AUTOSTART="false"

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi
export EDITOR='nano'
# Compilation flags
export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#alias exit="tmux detach; exit"

if command -v exa; then
	alias ls="exa -a --icons --git --group-directories-first"
	alias lsall="exa -alg --icons --git --group-directories-first"
else
	alias ls="ls --color"
	alias lsall="ls -al"
fi

if command -v tree; then
	alias tree="tree -a -C"
fi

alias cls="clear"

if command -v btop; then
	alias top="btop"
fi

if command -v nano; then
	alias pico="nano"
fi

if command -v op; then
	alias 1p="op"
fi

if [ -e "/Applications/Sublime Text.app/Contents/MacOS/sublime_text" ]; then
	function sublime() {
		"/Applications/Sublime Text.app/Contents/MacOS/sublime_text" $* &
	}
	#alias pico="\"/Applications/Sublime Text.app/Contents/MacOS/Sublime_Text\""
fi

if [ -e "/opt/sublime_text/sublime_text" ]; then
	alias sublime="/opt/sublime_text/sublime_text"
	alias pico="sublime"
fi

if command -v python3; then
	alias pip="python3 -m pip"
elif command -v python; then
	alias pip="python -m pip"
fi

if command -v fdfind; then
	alias find="fdfind"
fi

if command -v fd; then
	alias find="fd"
fi

if command -v rg; then
	alias grep="rg"
fi

if command -v batcat; then
	alias cat="batcat"
fi

if command -v bat; then
	alias cat="bat"
fi

if command -v tldr; then
	alias man="tldr"
	alias manman="/usr/bin/man"
fi

#Git Aliases
if command -v git; then
	git config --global user.email "candice@candicejoy.com"
	git config --global user.name "CandiceJoy"

	GPG_BINARY=$(command -v gpg)

	if [ "$GPG_BINARY" ] && [[ $(gpg --list-keys --keyid-format=long |grep $GPG_KEY_ID) ]]; then	
		git config --global user.signingkey "$GPG_KEY_ID"
		git config --global gpg.program "$GPG_BINARY"
		git config --global commit.gpgsign true
		git config --global tag.forceSignAnnotated true
	else
		echo "Error: GPG setup not found"
		echo "GPG Binary: $GPG_BINARY"
		echo "GPG Key ID: $GPG_KEY_ID"
		echo "GPG Keys (Filtered): $(gpg --list-keys --keyid-format=long |grep $GPG_KEY_ID)"
	fi

	alias commit="git commit -a"
	alias push="git push"
	alias clone="git clone"
	alias add="git add ."
	alias cpush="git add .; commit; push"
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  alias routes='netstat -nr -f inet'
INSTANTCLIENT=/Users/Candice/Oracle/18c
export PATH=$INSTANTCLIENT:$PATH
export ORACLE_HOME=$INSTANTCLIENT
export DYLD_LIBRARY_PATH=$INSTANTCLIENT
export OCI_LIB_DIR=$INSTANTCLIENT
export OCI_INC_DIR=$INSTANTCLIENT/sdk/include
fi

source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

if command -v brew; then
	BREWPATH=$(command -v brew)
	export PATH="$BREWPATH:$PATH"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export SSH_AUTH_SOCK=/Users/candice/Library/Containers/org.hejki.osx.sshce.agent/Data/socket.ssh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
