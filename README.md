With a local maintained in a seperate git repo
==============================================
```
#! /usr/bin/env zsh

git clone git@bitbucket.org:ender341/dotfiles.git "${HOME}/.dotfiles"
DOTFILES_LOCAL_GIT_REPO=${REPO_URL} zsh #{HOME}/.dotfiles/init.sh
```

With a locally maintained local
===============================
```
#! /usr/bin/env zsh

git clone git@bitbucket.org:ender341/dotfiles.git "${HOME}/.dotfiles"
/usr/bin/env zsh "${HOME}/.dotfiles/init.sh"

```
