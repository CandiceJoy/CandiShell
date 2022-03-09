import {createRequire} from "module";

const require = createRequire(import.meta.url);
const fs = require("fs");
const exec = require("child_process");
const os = require("os");
const paths = require("path");
const url = require("url");
const __filename = url.fileURLToPath(import.meta.url)
const __dirname = paths.dirname(__filename)

const mac = os.type().includes("Darwin");
console.log("OS: " + (mac) ? "Mac" : "Linux");
const brewPath = "/opt/homebrew/bin/";
const brewInstall = "brew install ";
const aptPath = "/usr/bin/";
const aptInstall = "sudo apt-get -y install ";
const debug = false;
const renamedZshrc = fixPath("~/.zshrc.pre-oh-my-zsh");
const defaultZshrc = fixPath("~/.zshrc");

const prereqs = [{
	linuxName   : "APT",
	macName     : "Brew",
	linuxCheck  : aptPath+"apt",
	linuxInstall: "",
	macCheck    : "/opt/homebrew/bin/brew",
	macInstall  : "wget -O ~/install.sh https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh; chmod a+x ~/install.sh; ~/install.sh; rm ~/install.sh"
}, {
	name        : "ZSH",
	linuxCheck  : aptPath+"zsh",
	linuxInstall: aptInstall + "zsh",
	macCheck    : "/bin/zsh",
	macInstall  : brewInstall + "zsh"
},/*{
	name        : "Exa",
	linuxCheck  : aptPath+"exa",
	linuxInstall: aptInstall + "exa",
	macCheck    : brewPath + "exa",
	macInstall  : brewInstall + "exa"
},*/ {
	name        : "Tmux",
	linuxCheck  : aptPath+"tmux",
	linuxInstall: aptInstall + "tmux",
	macCheck    : brewPath + "tmux",
	macInstall  : brewInstall + "tmux"
}, {
	name        : "Autojump",
	linuxCheck  : aptPath+"autojump",
	linuxInstall: aptInstall + "autojump",
	macCheck    : brewPath + "autojump",
	macInstall  : brewInstall + "autojump"
}, {
	name        : "Fzf",
	linuxCheck  : aptPath+"fzf",
	linuxInstall: aptInstall + "fzf",
	macCheck    : brewPath + "fzf",
	macInstall  : brewInstall + "fzf"
}, {
	macName     : "Reattach to User Namespace",
	linuxName   : "xClip",
	linuxCheck  : aptPath+"xclip",
	linuxInstall: aptInstall + "xclip",
	macCheck    : brewPath + "reattach-to-user-namespace",
	macInstall  : brewInstall + "reattach-to-user-namespace"
}, {
	name        : "Tree",
	linuxCheck  : aptPath+"tree",
	linuxInstall: aptInstall + "tree",
	macCheck    : brewPath + "tree",
	macInstall  : brewInstall + "tree"
}, {
	name        : "Wget",
	linuxCheck  : aptPath+"wget",
	linuxInstall: aptInstall + "wget",
	macCheck    : brewPath + "wget",
	macInstall  : brewInstall + "wget"
}, {
	name        : "Curl",
	linuxCheck  : aptPath+"curl",
	linuxInstall: aptInstall + "curl",
	macCheck    : ["/usr/bin/curl", brewPath + "curl"],
	macInstall  : brewInstall + "curl"
}, {
	name        : "Git",
	linuxCheck  : aptPath+"git",
	linuxInstall: aptInstall + "git",
	macCheck    : ["/usr/bin/git", brewPath + "git"],
	macInstall  : brewInstall + "git"
}, {
	name   : "Oh My ZSH",
	check  : "~/.oh-my-zsh",
	install: `wget -O ~/install.sh https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh; chmod a+x ~/install.sh; ~/install.sh --unattended; rm ~/install.sh; sudo chsh -s "/usr/bin/zsh" "$USER"`
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
}, {
	name   : "Tmux Plugin Manager",
	check  : "~/.tmux/plugins/tpm/tpm",
	install: "git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
}];

checkConfigs();
processPrereqs();
tmuxRefresh();
zshRefresh();

function checkConfigs()
{
	fs.cpSync(paths.join(__dirname, ".zshrc"), fixPath("~/.zshrc"));
	fs.cpSync(paths.join(__dirname, ".tmux.conf"), fixPath("~/.tmux.conf"));
}

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
	return path.replaceAll("~", process.env.HOME);
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


		if(fs.existsSync(renamedZshrc))
		{
			fs.cpSync(renamedZshrc, defaultZshrc);
			fs.rmSync(renamedZshrc);
		}
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
	//run("tmux source ~/..tmux.conf");
}

function run(command)
{
	let runme = command;

	if(!(command.includes(aptInstall) || command.includes(brewInstall) || command.includes("sh -c")))
	{
		runme = "";

		if(mac)
		{
			runme = `export PATH="${brewPath}:$PATH"; `;
		}

		runme += `zsh -c "${command}"`;
	}

	if(debug)
	{
		console.log("Would run '" + runme + "'");
	}
	else
	{
		const proc = exec.execSync(runme, (error, stdout, stderr) =>
		{
			const tmuxError = "no server running on ";

			if(error.message.includes(tmuxError) || stderr.includes(tmuxError))
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

			if(stderr || error)
			{
				process.exit(1);
			}
		});
	}
}