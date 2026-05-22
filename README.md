# Setup

First, clone this repository.

## Automatic Installation

You can automate the installation of bash, vim, neovim, and tmux configurations by running:

```sh
$ make install
```

This runs `./install.sh` under the hood.

You can also run sandboxed tests to verify the installation logic before applying it:

```sh
$ make test # or simply `make`
```

After running the script, you still need to perform these manual steps:
1. Run `tmux` and press `Ctrl-A I` to install plugins.
2. Install the [Hack font](https://github.com/source-foundry/Hack) (recommended for gnome-terminal).
3. Apply the gruvbox8 theme to gnome-terminal (see below).

## Manual Installation

If you prefer to configure everything manually, follow the sections below.

## Configure bash

Add the following to your .bashrc:

```sh
# Use vim for editing.
export VISUAL="vim"
export EDITOR="${VISUAL}"

# Better prompt.
source ~/dotfiles/prompt.sh
```

## Configure vim

Install the [gruvbox8](https://github.com/lifepillar/vim-gruvbox8) colorscheme,
specifically the `gruvbox8_hard` variant:

```sh
$ curl -Lo ~/.vim/colors/gruvbox8_hard.vim --create-dirs \
  https://raw.githubusercontent.com/lifepillar/vim-gruvbox8/master/colors/gruvbox8_hard.vim
```

Then configure vim to use the configs in this repo by adding the following to
`~/.vimrc`:

```
" Load configuration plugins from central dotfiles.
set runtimepath^=~/code/dotfiles/vim
```

## Configure neovim

Use the `nvim` subdirectory as your neovim configuration:

```sh
$ ln -s ~/code/dotfiles/nvim ~/.config/nvim
```

Install the `gruvbox8` theme for neovim:

```sh
$ curl -Lo ~/.local/share/nvim/site/colors/gruvbox8_hard.vim --create-dirs \
  https://raw.githubusercontent.com/lifepillar/vim-gruvbox8/master/colors/gruvbox8_hard.vim
```

## Configure tmux

Install [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm):

```sh
$ git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Run the following command:

```sh
$ ln -s ~/dotfiles/tmux.conf ~/.tmux.conf
```

Then run tmux, and type `<Ctrl>-A I` to install plugins.

If the prompt in tmux is not colored, and backspace does not work, the system
might be missing the `tmux` terminfo file. On Debian-based distros, that file is
provided by the `ncurses-term` package:

```sh
$ sudo apt install ncurses-term
```

## Configure gnome-terminal

Install the [Hack font](https://github.com/source-foundry/Hack).

Apply the gruvbox8 theme using
[gnome-terminal-configure](https://github.com/letitz/gnome-terminal-configure).

## Add utility scripts

Add `bin/` to your `$PATH`. Edit your `.bashrc`:

```
export PATH=$PATH:$HOME/dotfiles/bin
```
