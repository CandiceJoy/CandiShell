#!node
import fs        from "fs";
import exec from "child_process";
import os        from "os";

const mac = os.type().includes("Darwin");
console.log("OS: " + (mac) ? "Mac" : "Linux");
const brewPath = "/opt/homebrew/bin/";
const brewInstall = "brew install ";
const aptInstall = "sudo apt-get -y install ";
const debug = false;

const zshrc = `
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"
#ZSH_THEME="apple"
#ZSH_THEME="fletcherm"
#ZSH_THEME="tjkirch"
#ZSH_THEME="xiong-chiamiov"
ZSH_THEME="headline"

alias cls="clear"
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

export ZSH_TMUX_AUTOSTART="true"

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
# For a full list of active aliases, run \`alias\`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias exit="tmux detach"
source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
`;

const tmuxConf = `
set-option -g mouse on
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'jaclu/tmux-menus'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @sidebar-tree-command 'tree -C'
set -g @plugin 'tmux-plugins/tmux-sidebar'
set -g @plugin 'tmux-plugins/tmux-copycat'
run '~/.tmux/plugins/tpm/tpm'
`;

const prereqs = [{
	linuxName   : "APT",
	macName     : "Brew",
	linuxCheck  : "/usr/bin/apt",
	linuxInstall: "",
	macCheck    : "/opt/homebrew/bin/brew",
	macInstall  : "wget -O ~/install.sh https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh; chmod a+x ~/install.sh; ~/install.sh; rm ~/install.sh"
}, {
	name        : "ZSH",
	linuxCheck  : "/usr/bin/zsh",
	linuxInstall: aptInstall + "zsh",
	macCheck    : "/bin/zsh",
	macInstall  : brewInstall + "zsh"
}, {
	name        : "Tmux",
	linuxCheck  : "/usr/bin/tmux",
	linuxInstall: aptInstall + "tmux",
	macCheck    : brewPath + "tmux",
	macInstall  : brewInstall + "tmux"
}, {
	name        : "Autojump",
	linuxCheck  : "/usr/bin/autojump",
	linuxInstall: aptInstall + "autojump",
	macCheck    : brewPath + "autojump",
	macInstall  : brewInstall + "autojump"
}, {
	name        : "Fzf",
	linuxCheck  : "/usr/bin/fzf",
	linuxInstall: aptInstall + "fzf",
	macCheck    : brewPath + "fzf",
	macInstall  : brewInstall + "fzf"
}, {
	macName     : "Reattach to User Namespace",
	linuxName   : "xClip",
	linuxCheck  : "/usr/bin/xclip",
	linuxInstall: aptInstall + "xclip",
	macCheck    : brewPath + "reattach-to-user-namespace",
	macInstall  : brewInstall + "reattach-to-user-namespace"
}, {
	name        : "Tree",
	linuxCheck  : "/usr/bin/tree",
	linuxInstall: aptInstall + "tree",
	macCheck    : brewPath + "tree",
	macInstall  : brewInstall + "tree"
}, {
	name        : "Wget",
	linuxCheck  : "/usr/bin/wget",
	linuxInstall: aptInstall + "wget",
	macCheck    : brewPath + "wget",
	macInstall  : brewInstall + "wget"
}, {
	name        : "Curl",
	linuxCheck  : "/usr/bin/curl",
	linuxInstall: aptInstall + "curl",
	macCheck    : ["/usr/bin/curl", brewPath + "curl"],
	macInstall  : brewInstall + "curl"
}, {
	name        : "Git",
	linuxCheck  : "/usr/bin/git",
	linuxInstall: aptInstall + "git",
	macCheck    : ["/usr/bin/git", brewPath + "git"],
	macInstall  : brewInstall + "git"
}, {
	name   : "Oh My ZSH",
	check  : "~/.oh-my-zsh",
	install: `wget -O ~/install.sh https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh; chmod a+x ~/install.sh; ~/install.sh --unattended; rm ~/install.sh; sudo chsh -s "/usr/bin/zsh" "$USER"`,
}, {
	name   : "ZSH Syntax Highlighting",
	check  : "~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh",
	install: "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
}, {
	name   : "ZSH Autosuggestions",
	check  : "~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh",
	install: "git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
}, {
	name   : "Headline Theme",
	check  : "~/.oh-my-zsh/custom/themes/headline.zsh-theme",
	install: "wget -O ~/.oh-my-zsh/custom/themes/headline.zsh-theme https://raw.githubusercontent.com/moarram/headline/main/headline.zsh-theme"
},{
	name:"Tmux Plugin Manager",
	check:"~/.tmux/plugins/tpm/tpm",
	install:"git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
}];

processPrereqs();
createConfigs();
tmuxRefresh();
zshRefresh();

function processPrereqs()
{
	for(let i = 0; i < prereqs.length; i++)
	{
		const prereq = prereqs[i];

		if(mac)
		{
			processPrereq((prereq.name) ? prereq.name : prereq.macName, (prereq.check) ? prereq.check : prereq.macCheck,
			              (prereq.install) ? prereq.install : prereq.macInstall);
		}
		else
		{
			processPrereq((prereq.name) ? prereq.name : prereq.linuxName,
			              (prereq.check) ? prereq.check : prereq.linuxCheck,
			              (prereq.install) ? prereq.install : prereq.linuxInstall);
		}
	}
}

function fixPath(path)
{
	return path.replaceAll("~",process.env.HOME);
}

function processPrereq(name, check, install)
{
	let found = false;

	if(Array.isArray(check))
	{
		for(const i in check)
		{
			if(fs.existsSync(fixPath(check[i])))
			{
				found = true;
				break;
			}
		}
	}
	else
	{
		if(fs.existsSync(fixPath(check)))
		{
			found = true;
		}
	}

	if(!found)
	{
		console.log("Missing " + name + "; installing");
		run(install);
	}
	else
	{
		console.log(name + " found");
	}
}

function zshRefresh()
{
	run("source ~/.zshrc");
}

function tmuxRefresh()
{
	run("~/.tmux/plugins/tpm/bin/install_plugins");
	run("tmux source ~/.tmux.conf");
}

function createConfigs()
{
	fs.writeFileSync(fixPath((debug?".":"~")+"/.zshrc"),zshrc);
	fs.writeFileSync(fixPath((debug?".":"~")+"/.tmux.conf"),tmuxConf);
}

function run(command)
{
	let runme = command;

	if( !(command.includes(aptInstall ) || command.includes(brewInstall) || command.includes("sh -c") ) )
	{
		runme = "";

		if( mac )
		{
			runme= `export PATH="${brewPath}:$PATH"; `;
		}

		runme += `zsh -c "${command}"`;
	}

	if( debug )
	{
		console.log("Would run '" + runme + "'");
	}
	else
	{
		const proc = exec.execSync(runme, (error, stdout, stderr) =>
		{
			const tmuxError="no server running on ";

			if( error.message.includes(tmuxError) || stderr.includes(tmuxError))
			{
				console.log("Initial setup complete; log back in for everything to take effect :)");
				process.exit(0);
			}

			if(error)
			{
				console.error(error.message);
			}

			if(stderr)
			{
				console.log("stderr: " + stderr);
			}

			if(stdout)
			{
				console.log(stdout);
			}

			if( stderr||error )
			{
				process.exit(1);
			}
		});
	}
}