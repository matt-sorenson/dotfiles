# These aliases are sourced in zshrc.zsh, so only available in interactive shells.

alias ls='ls --time-style=long-iso --color=auto'
alias vi=vim

alias strip-color-codes="perl -pe 's/\e\[?.*?[\@-~]//g'"

# pbpaste is osx specific, try a few fallback options if available.
if ! command -v pbpaste > /dev/null; then
    if command -v xsel > /dev/null; then
        alias pbpaste='xsel --clipboard --output'
    elif command -v xclip > /dev/null; then
        alias pbcopy='xclip -selection clipboard'
    fi
fi
