wsl-clone() {
    ws-clone --cmd-name "wsl-clone" --root /mnt/d/ws --soft-link "${WORKSPACE_ROOT_DIR}" "$@"
}

# Because [_ws-clone] has the '-' in it we use this strange syntax...
typeset 'dotfiles_completion_functions[_ws-clone]'='wsl-clone'
