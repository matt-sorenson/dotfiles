# These aliases are sourced in zshrc.zsh, so only available in interactive shells.

if ls --version &> /dev/null; then
    # GNU ls
    # --time-style=long-iso gives a more readable date format
    alias ls='ls --time-style=long-iso --color=auto'
else
    # -G enable colorized output
    # -D '%FT%T' gives a more readable date format
    alias ls='ls -G -D "%FT%T%z"'
fi

alias vi=vim # Ugg, I hate plain vi
alias zrestart="exec zsh"
alias strip-color-codes="perl -pe 's/\e\[?.*?[\@-~]//g'"

# pbpaste is osx specific, try a few fallback options if available.
if ! command -v pbpaste > /dev/null; then
    if command -v xsel > /dev/null; then
        alias pbpaste='xsel --clipboard --output'
    elif command -v xclip > /dev/null; then
        alias pbcopy='xclip -selection clipboard'
    fi
fi
