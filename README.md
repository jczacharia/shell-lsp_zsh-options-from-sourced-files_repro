# shell-lsp: options set by a sourced zsh file are ignored

Reproduction for [stubbedev/shell-lsp#ISSUE](https://github.com/stubbedev/shell-lsp/issues/ISSUE).

`lib/options.zsh` turns on `pipe_fail` and `extended_glob`. Two scripts do the same thing:

| Script | Options come from |
|---|---|
| `bin/sourced.zsh` | `source "$(dirname "$0")/../lib/options.zsh"` |
| `bin/inline.zsh` | `setopt pipe_fail extended_glob` on its own line 2 |

`source` runs the file in the current shell, so its `setopt` stays in effect afterwards and the two scripts behave identically:

```console
$ zsh bin/sourced.zsh
matched: extended_glob is on
yes
```

shell-lsp follows the sourced file (no SC1091, no directive needed), but checks `bin/sourced.zsh` as if the options were off:

```console
$ shell-lsp check --profile strict -f gcc bin
bin/sourced.zsh:5:20: warning: (#i) is an extended glob operator, and this file never runs `setopt extendedglob`, so zsh matches it literally. [SL2016]
bin/sourced.zsh:8:1: note: This command's exit status is masked by its context; run it separately or append || true if failure does not matter. [SC2312]
```

- **SL2016** (default profile too) says `(#i)yes` is matched literally; zsh's output above shows it is not.
- **SC2312** (`check-extra-masked-returns`) says the pipeline masks `print`'s status; with `pipe_fail` on it does not.

`bin/inline.zsh` gets neither finding.

## Run it without cloning

```sh
nix run github:jczacharia/shell-lsp_zsh-options-from-sourced-files_repro
```

Builds shell-lsp v0.5.21 from its tag and lints `bin/`.

## Run it from a clone

```sh
nix develop      # or direnv; provides just, zsh and shell-lsp v0.5.21
just zsh         # both scripts print "matched: extended_glob is on"
just before      # shell-lsp v0.5.21: SL2016 and SC2312 on bin/sourced.zsh only
just after       # shell-lsp built from the fix branch: nothing reported, exit 0
```

`just after FLAKE` builds any other shell-lsp, e.g. `just after github:stubbedev/shell-lsp` for upstream `main`, or `just after git+file:///path/to/shell-lsp` for a local checkout.
