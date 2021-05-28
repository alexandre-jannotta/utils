
. "${HOME}/.profile"

_RESET='\[\033[0m\]'
_BLACK=$(tput setaf 0)
_RED=$(tput setaf 1)
_GREEN=$(tput setaf 2)
_YELLOW=$(tput setaf 3)
_DARK_BLUE=$(tput setaf 4)
_PURPLE=$(tput setaf 5)
_LIGHT_BLUE=$(tput setaf 6)
_LIGHT_GRAY=$(tput setaf 7)
_GRAY=$(tput setaf 8)
_LIGHT_RED=$(tput setaf 9)
_LIGHT_GREEN=$(tput setaf 10)
_LIGHT_YELLOW=$(tput setaf 11)
_BLUE=$(tput setaf 12)
_PINK=$(tput setaf 13)
_TURQUOISE=$(tput setaf 14)
_WHITE=$(tput setaf 15)

PS1="\n$_DARK_BLUE╭─[$_YELLOW\h$_DARK_BLUE]─[$_LIGHT_RED\u$_DARK_BLUE]─[$_LIGHT_GREEN\w$_DARK_BLUE] \n└> $_RESET"

# man colors
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

command -v lsd > /dev/null && alias ls='lsd --group-dirs first'
command -v lsd > /dev/null && alias ls='lsd --tree'
command -v htop > /dev/null && alias top='htop'

export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0
export LIBGL_ALWAYS_INDIRECT=1

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
#eval "$(pyenv virtualenv-init -)"

# veolia...
#export NO_NOUNSET="nope"
#export NO_PIPEFAIL="nope"

update_gitkraken() {
    wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
    sudo dpkg -i gitkraken-amd64.deb
    rm gitkraken-amd64.deb
}

update_aws() {
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	sudo ./aws/install --update
	aws --version
}

update_pyenv() {
	pyenv update

	pyenv install-latest 3.9
	pyenv global $(pyenv install-latest --print 3.9)
}

update() {
    sudo apt update
    sudo apt upgrade -y
}

venv() {
	if [[ -z "$1" ]]; then
		venv '.venv'
	else
		echo "python -m venv $1"
		python3 -m venv $1
    fi
}

activate() {
	if [[ -z "$1" ]]; then
		activate '.venv'
	else
        source_path="$1/bin/activate"
		echo "$source_path"
		source $source_path
    fi
}

pip_install() {
	python3 -m pip install --upgrade pip
	pip install -r requirements.txt
}
