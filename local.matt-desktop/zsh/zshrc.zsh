wsl-clone() {
    ws-clone --cmd-name "wsl-clone" --root /mnt/d/ws --soft-link "${WORKSPACE_ROOT_DIR}" "$@"
}

# Because [wsl-clone] has the '-' in it we use this strange syntax...
typeset 'dotfiles_completion_functions[wsl-clone]'='_ws-clone'
