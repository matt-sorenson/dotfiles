# Setup

In ./local/zshrc.zsh make sure to add `DOT_DEFAULT_REPO='<whatever repo name>'`
if you plan on using repoman. See templates/ for an example of how to use it.

# With a local maintained in a seperate git repo

```
#! /usr/bin/env zsh

git clone git@github.com:matt-sorenson/dotfiles.git "${HOME}/.dotfiles"
DOTFILES_LOCAL_GIT_REPO=${REPO_URL} zsh #{HOME}/.dotfiles/init.sh
```

# With a locally maintained local

```
#! /usr/bin/env zsh

git clone git@github.com:matt-sorenson/dotfiles.git "${HOME}/.dotfiles"
/usr/bin/env zsh "${HOME}/.dotfiles/init.sh"

```
