# Setup

In ./local/zshrc.zsh make sure to add `DOT_DEFAULT_REPO='<whatever repo name>'`
if you plan on using repoman. See templates/ for an example of how to use it.

## Matt's default
```zsh
git clone git@github.com:matt-sorenson/dotfiles.git "${HOME}/.dotfiles"

~/.dotfiles/init.sh --git-email-matt --work
```

## Other example

```zsh

git clone git@github.com:matt-sorenson/dotfiles.git "${HOME}/.dotfiles"

~/.dotfiles/init.sh \
    # This creates the ${DOTFILES}/local/is_work file
    # Hammerspoon uses this for filtering screen layouts & for not trying
    # to attach personal shared drives to work computer
    # Scripts can also use it.
    --work
    # Email to use when commiting to dotfiles
    # This is so you don't use your work email for this particular repo if you
    # don't want to.
    --git-email 'foo@example.com'
    # Use this if you have a seperate repo you use as `local`
    # I don't keep these in this same repo as it contains work specific code
    # and I'm not taking that off of work's cloud
    --plugin 'local=https://github.com/...'
```
