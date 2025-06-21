#!/usr/bin/env zsh

if (( $# == 0 )) || [[ -z "$1" ]]; then
  print-header -e "Script name not provided." >&2
  exit 1
fi

if (( $# > 1 )); then
  print-header -e "To many arguments provided \`$*\`." >&2
  exit 1
fi

name="$1"

template="${DOTFILES}/templates/bin/new_script.zsh"
target="${DOTFILES}/bin/${name}.zsh"

if [[ ! -r "$template" ]]; then
  print-header -e "Template '$template' not found." >&2
  exit 1
fi

if [[ -e "$target" ]]; then
  print-header -e "File '$target' already exists." >&2
  exit 1
fi

mkdir -p bin

# Replace <name> with the input value
sed "s/<name>/${name}/g" "$template" > "$target"
chmod 700 "$target"

print-header green "✅ Created: $target"
