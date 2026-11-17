# Reproduction for shell-lsp: options set by a sourced zsh file are not seen in the file that sources it.
# `just` lists the recipes; `just zsh`, `just before`, `just after` tell the story in order.

# The fix to compare against; any flake reference works. A local checkout needs git+file:///path/to/shell-lsp
# (its package reads git-tracked files, so path: refs fail; uncommitted edits to tracked files are included).
fix := "github:jczacharia/shell-lsp?ref=fix/options-from-sourced-files"

default:
    @just --list

# Run both scripts with zsh: both print the line that only an extended glob can match.
zsh:
    for f in bin/*.zsh; do echo "== $f"; zsh -f "$f"; done

# Lint with shell-lsp v0.5.21: SL2016 and SC2312 on bin/sourced.zsh only.
before:
    nix run path:.#before

# Lint with shell-lsp built from FLAKE; exits 0 only when nothing is reported.
after flake=fix:
    nix run '{{ flake }}' -- --version
    nix run '{{ flake }}' -- check --profile strict -f gcc bin
