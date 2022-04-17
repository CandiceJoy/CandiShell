#!/usr/bin/perl
use warnings;
use strict;
use File::Compare;

my $home = $ENV{"HOME"};
my $user = $ENV{"USER"};
my $end = color(0)."\n";

sub color
{
	my $num=$_[0];
	return "\e[".$num."m";
}

sub check_command
{
	my $cmd = $_[0];
	my $ret = `command -v $cmd`;

	if( $ret )
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

my $reset = color 0;
my $red = color 31;
my $yellow = color 33;
my $blue = color 34;
my $green = color 32;
my $magenta = color 35;
my $cyan = color 36;
my $noupdate = 0;
my $force = 0;
my $nobrew = 0;
my $no_cleanup = 0;
my $debug = 0;

for( @ARGV )
{
	my $arg = $_;
	my $lc_arg = lc($arg);

	if( $lc_arg eq "--noupdate" )
	{
		$noupdate = 1;
		print("${yellow}--noupdate detected; will not update script$end");
	}
	elsif( $lc_arg eq "--force" )
	{
		$force = 1;
		print("${yellow}--force detected; will overwrite configs$end");
	}
	elsif( $lc_arg eq "--no-cleanup" )
	{
		$no_cleanup = 1;
		print("${yellow}--no-cleanup detected; will not clean up$end");
	}
	elsif( $lc_arg eq "--debug" )
	{
		$debug = 1;
		print("${yellow}--debug detected; enabling debug mode$end");
	}
	else
	{
		print( "Unidentified parameter: $arg$end" );
		exit 0;
	}
}

sub cleanup
{
	if( !$no_cleanup )
	{
		`rm -rf $home/candishell`;
	}
}

my $mac = 0;
my $linux = 1;

if( $^O eq "darwin" )
{
	$mac = 1;
	$linux = 0;
}

`git config --global core.autocrlf false`;
`git config --global core.eol lf`;
cleanup;
`git clone https://github.com/CandiceJoy/CandiShell.git $home/candishell`;

if( !$noupdate )
{
	my $compare = compare("$home/candishell.pl","$home/candishell/candishell.pl");

	if( $compare )
	{
		`cp $home/candishell/candishell.pl $home/candishell.pl`;
		cleanup;
		print "${cyan}Script updated; please re-rerun$end";
		exit(0);
	}
}

my $brew = "brew install";
my $apt = "sudo apt install";
my $npm = "sudo npm -g i";
my $install = "";

if( $mac )
{
	$install = $brew;
}

if( $linux )
{
	$install = $apt;
}

sub install
{
	my $args = @_;
	my $name = $_[0];
	my $check = $_[1];
	my $install_command = "";

	if( $args >= 3 )
	{
		$install_command = $_[2];
	}
	else
	{
		$install_command = $install;
	}

	if( $debug )
	{
		print("-----\nInstall\nname: $name\ncheck: $check\ninstall command: $install_command\n");
	}

	print( $blue."Checking $name$reset\n" );

	if( !check_command( $check ) )
	{
		print( "${yellow}Missing; Installing$reset\n" );
		print( "$install_command$end" );
		`$install_command`;

		if( !check_command( $check ) )
		{
			print( "${red}Installation failed$end" );
			exit 1;
		}
	}
	else
	{
		print( "${green}Found$end" );
	}
}

sub update
{
	my $args = @_;
	my $name = $_[0];
	my $src = "$home/candishell/$_[1]";
	my $dest = "";
	my $dontoverwrite = 0;

	if( $args >= 3 )
	{
		$dest = "$home/$_[2]";
	}
	else
	{
		$dest = "$home/$_[1]";
	}

	if( $args >= 4 )
	{
		$dontoverwrite = $_[3];
	}
	else
	{
		$dontoverwrite = 0;
	}

	if( $debug )
	{
		print("-----\nUpdate\nsrc: $src\ndest: $dest\nname: $name\ndontoverwrite: $dontoverwrite\n");
	}
	
	print( "${blue}Checking $name$end" );

	if( compare( $src, $dest ) )
	{
		if( !$dontoverwrite || $force )
		{
			print( "${yellow}Updating$end" );
			`cp $src $dest`;
		}
		else
		{
			print( "${yellow}Skipping$end" );
		}
	}
	else
	{
		print("${green}Already latest version$end");
	}
}

sub install_noexec
{
	my $name = $_[0];
	my $check = "$home/$_[1]";
	my $install_command = $_[2];

	if( $debug )
	{
		print("-----\nInstall NoExec\nname: $name\ncheck: $check\ninstall command: $install_command\n");
	}

	print( "${blue}Checking $name$end" );

	if( ! -e $check )
	{
		print( "${yellow}Missing; Installing$end" );
		`$install_command`;
	}
	else
	{
		print("${green}Found$end");
	}
}

if( $mac )
{
	install("Homebrew","brew","/bin/bash -c \"curl -fsSLO https://raw.githubusercontent.com/Homebrew/install/master/install.sh; chmod +x install.sh; ./install.sh\"");
	install("WGet","wget");
	install("Git - Mac","git");
	install("NodeJS - Mac","node");
	install("NPM - Mac","npm");
}

if( $linux )
{
	if( !check_command "apt" )
	{
		print( "${magenta}Requires APT$end" );
		exit 1;
	}
	else
	{
		print( "${green}APT Found; continuing$end" );
	}

	install("NodeJS - Linux","node","$install nodejs");
	install("NPM - Linux","npm");

	if( -e "/home/linuxbrew/.linuxbrew/bin/brew" && !check_command "brew" )
	{
		print( "${yellow}Brew installed but not in path; manually setting it up for this shell$end");
		$ENV{"PATH"} = "/home/linuxbrew/.linuxbrew/bin:".$ENV{"PATH"};
		$brew = "/home/linuxbrew/.linuxbrew/bin/brew install";
	}
	else
	{
		if( !check_command "brew" )
		{
			`wget -O $home/install.sh https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh; chmod a+x $home/install.sh; $home/install.sh; rm $home/install.sh`;
		}

		if( -e "/home/linuxbrew" && ! `ls /home/linuxbrew` )
		{
			`sudo groupadd brew; sudo chgrp -R brew /home/linuxbrew; sudo chmod 754 /home/linuxbrew; sudo usermod -a -G brew $user`;
		}

		if( ! -e "/home/linuxbrew" )
		{
			$nobrew = 1;
		}
	}
}

install("N","n","$npm n");

my $node_version = `node -v | cut -c2-3`;

if( $node_version <= 15 )
{
	`sudo n stable`;

	$node_version = `node -v | cut -c2-3`;

	if( $node_version <= 15 )
	{
		print( "${cyan}You will ahve to exit the shell and try again.$end" );
		exit 0;
	}
	else
	{
		print( "${green}Node version good; continuing$end" );
	}
}

if( $mac )
{
	install("Reattach to User Namespace - Mac","reattach-to-user-namespace");
	install("BTop - Mac","btop");
	install("Bat - Mac","bat");
	install("FD - Mac","fd");
	install("RipGrep - Mac","rg","$install ripgrep");
}

if( $linux )
{
	install("XClip - Linux","xclip");
	install("BTop - Linux","btop","$brew btop");
	install("FD - Linux","fdfind","$install fd-find");
	install("RipGrep - Linux","rg","sudo apt install -o Dpkg::Options::=\"--force-overwrite\" bat ripgrep");
	install("Bat - Linux","batcat","sudo apt install -o Dpkg::Options::=\"--force-overwrite\" bat ripgrep");
}

install("ZSH","zsh");

if( !$nobrew )
{
	install("Exa","exa","$brew exa");
}

install("Dos2Unix","dos2unix");
install("TMUX","tmux");
install("AutoJump","autojump");
install("FZF","fzf");
install("Tree","tree");
install("cURL","curl");
install("IFTop","iftop");
install("LNav","lnav");
install("NNN","nnn");
install("FKill","fkill","$npm fkill-cli");
install("TLDR","tldr","$npm tldr");

my $zsh_path = `command -v zsh`;

install_noexec("Oh My ZSH",".oh-my-zsh","wget -O ~/install.sh https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh; chmod a+x ~/install.sh; ~/install.sh --unattended; rm ~/install.sh; sudo chsh -s \"$zsh_path\" \"$user\"");
install_noexec("ZSH Syntax Highlighting",".oh-my-zsh/custom/plugins/zsh-syntax-highlighting","git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting");
install_noexec("ZSH Autosuggestions",".oh-my-zsh/custom/plugins/zsh-autosuggestions","git clone https://github.com/zsh-users/zsh-autosuggestions \${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions");
install_noexec("Powerline 10k Theme",".oh-my-zsh/custom/themes/powerlevel10k","git clone https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k");
install_noexec("TMUX Plugin Manager",".tmux/plugins/tpm","git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm");
install_noexec("Nano Highlighting",".nano","curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh");
update("ZSH Config",".zshrc");
update("TMUX Config",".tmux.conf");
update("P10K Settings",".p10k.zsh",".p10k.zsh","true");
update("Remote Change Script","remote.sh");
update("SSH Config","config",".ssh/config");

cleanup;
print( "${cyan}Run source ~/.zshrc to update$end" );