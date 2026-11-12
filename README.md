# dotfiles-bootstrap

Public entry point for bootstrapping a Mac with a private setup repository.
Requires an interactive macOS Terminal and a GitHub account with access to the
private repository. No credentials or personal configuration are stored here.

## Read before you run

Read [bootstrap.sh](bootstrap.sh) and the private repository's setup instructions
before running. This installs software and then executes the private bootstrap.
Homebrew may request your Mac password; GitHub login uses your browser.

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/davidandradeduarte/dotfiles-bootstrap/main/bootstrap.sh)"
```

To download and inspect first, run these commands separately, then run the last
command only after reviewing the downloaded file:

```sh
curl -fsSL https://raw.githubusercontent.com/davidandradeduarte/dotfiles-bootstrap/main/bootstrap.sh -o /tmp/dotfiles-bootstrap.sh
less /tmp/dotfiles-bootstrap.sh
/bin/bash /tmp/dotfiles-bootstrap.sh
```

## What it does

1. Checks that the system is macOS.
2. Requests Xcode Command Line Tools if missing and waits for installation.
   Complete the macOS dialog; press Control-C to stop waiting if you cancel it.
3. Installs [Homebrew](https://brew.sh) using its official installer if missing,
   loads `brew shellenv`, and adds it once to `~/.zprofile`, including Apple Silicon.
4. Installs the `gh` and `git` formulae if missing.
5. Checks GitHub authentication; when missing, starts browser login over HTTPS
   requesting the `repo` scope for private repository access.
6. Clones `davidandradeduarte/dotfiles-agentic` to `~/src/dotfiles-agentic`, or
   validates the existing checkout's origin and runs `git pull --ff-only`.
   Diverged branches require manual resolution; local changes are not discarded.
7. Executes `macos/scripts/bootstrap.sh` from that checkout. The private script
   handles AI agent selection, opening it, and the ready-to-paste setup prompt.
   Its prerequisite checks reuse the tools and checkout prepared here.

Repeated runs reuse installed prerequisites and authentication, avoid duplicate
shell profile entries, and update the checkout before handing off again. Agent
choices and personal setup remain in the private repository.

## Overrides

`DOTFILES_REPO` accepts a GitHub `owner/repo`; `DOTFILES_DIR` accepts a destination
path. The selected repository must provide `macos/scripts/bootstrap.sh` and honor
these variables if it needs them. Export either variable before the one-liner,
or use the inspected local file:

```sh
DOTFILES_REPO=example/setup DOTFILES_DIR="$HOME/src/setup" /bin/bash /tmp/dotfiles-bootstrap.sh
```

## License

[MIT](LICENSE).
