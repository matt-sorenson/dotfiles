wsl-clone() {
    ws-clone --cmd-name "wsl-clone" --root /mnt/d/ws --soft-link "${WORKSPACE_ROOT_DIR}" "$@"
}

compdef _ws-clone wsl-clone
