export DOTFILES="${DOTFILES:=${HOME}/.dotfiles}"

if [ -f "$DOTFILES/local/zsh/zshenv.zsh" ]; then
    source "$DOTFILES/local/zsh/zshenv.zsh"
fi

source "${DOTFILES}/zsh/path.zsh"

if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

export EDITOR='vim'
export VISUAL='vim'
export PAGER='less -FgMRXi'

if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

if [[ ! -d "$TMPDIR" ]]; then
  export TMPDIR="/tmp/$LOGNAME"
  mkdir -p -m 700 "$TMPDIR"
fi

TMPPREFIX="${TMPDIR%/}/zsh"
export HOMEBREW_GITHUB_API_TOKEN=e69a63365a3d4dffb9a26ed903ea7b5f1b44acaa
export HOMEBREW_NO_ANALYTICS=1
