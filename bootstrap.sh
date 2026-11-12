#!/bin/bash
# Public entry point; setup choices belong to the private repository.
set -euo pipefail

[ "$(uname -s)" = Darwin ] || { echo 'This bootstrap requires macOS.' >&2; exit 1; }

export DOTFILES_REPO="${DOTFILES_REPO:-davidandradeduarte/dotfiles-agentic}"
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/src/dotfiles-agentic}"

if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install || true
  echo 'Complete the Command Line Tools installation dialog. Waiting for installation...'
  until xcode-select -p >/dev/null 2>&1; do
    sleep 5
  done
fi

if command -v brew >/dev/null 2>&1; then
  brew_bin=$(command -v brew)
elif [ -x /opt/homebrew/bin/brew ]; then
  brew_bin=/opt/homebrew/bin/brew
elif [ -x /usr/local/bin/brew ]; then
  brew_bin=/usr/local/bin/brew
else
  installer=$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)
  /bin/bash -c "$installer"
  if [ -x /opt/homebrew/bin/brew ]; then
    brew_bin=/opt/homebrew/bin/brew
  else
    brew_bin=/usr/local/bin/brew
  fi
fi

eval "$("$brew_bin" shellenv)"
shellenv_line="eval \"\$(\"$brew_bin\" shellenv)\""
if [ ! -f "$HOME/.zprofile" ] || ! grep -Fqx "$shellenv_line" "$HOME/.zprofile"; then
  printf '\n%s\n' "$shellenv_line" >> "$HOME/.zprofile"
fi

# Skip installed formulae so repeated runs do not upgrade them.
for formula in gh git; do
  if ! brew list --formula "$formula" >/dev/null 2>&1; then
    brew install "$formula"
  fi
done

if ! gh auth status --hostname github.com >/dev/null 2>&1; then
  gh auth login --hostname github.com --git-protocol https --web --scopes repo
fi

if [ -e "$DOTFILES_DIR" ]; then
  checkout_root=$(git -C "$DOTFILES_DIR" rev-parse --show-toplevel)
  [ "$checkout_root" = "$(cd "$DOTFILES_DIR" && pwd -P)" ] || {
    echo 'Destination must be the root of a Git checkout.' >&2; exit 1;
  }
  remote=$(git -C "$DOTFILES_DIR" remote get-url origin)
  case "$remote" in
    "https://github.com/$DOTFILES_REPO"|"https://github.com/$DOTFILES_REPO.git"|"git@github.com:$DOTFILES_REPO.git") ;;
    *) echo 'Destination origin is not the expected repo; inspect it manually.' >&2; exit 1 ;;
  esac
  git -c 'credential.https://github.com.helper=!gh auth git-credential' -C "$DOTFILES_DIR" pull --ff-only
else
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  gh repo clone "https://github.com/$DOTFILES_REPO.git" "$DOTFILES_DIR"
fi

exec /bin/bash "$DOTFILES_DIR/macos/scripts/bootstrap.sh"
