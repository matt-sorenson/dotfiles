#! /usr/bin/env zsh

emulate -L zsh
set -euo pipefail
setopt typeset_to_unset

print-header "Starting create-zsh-script.zsh"

if (( $# == 0 )) || [[ -z "$1" ]]; then
  print-header -e "Script name not provided." >&2
  return 1
fi

if (( $# > 1 )); then
  print-header -e "To many arguments provided \`$*\`." >&2
  return 1
fi

name="$1"

template="${DOTFILES}/templates/bin/new_script.zsh"
target="${DOTFILES}/bin/${name}"

if [[ ! -r "$template" ]]; then
  print-header -e "Template '$template' not found." >&2
  return 1
fi

if [[ -e "$target" ]]; then
  print-header -e "File '$target' already exists." >&2
  return 1
fi

mkdir -p bin

# Replace <name> with the input value
sed "s/<name>/${name}/g" "$template" > "$target"
chmod 755 "$target"

code ${(q)target}

print-header green "✅ Created: $target"
