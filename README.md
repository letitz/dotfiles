# Setup

First, clone this repository into `~/dotfiles`.

## Configure bash

Add the following to your .bashrc:

```sh
# Better prompt.
source ~/dotfiles/prompt.sh
```

## Configure vim

Install the [gruvbox8](https://github.com/lifepillar/vim-gruvbox8) colorscheme,
specifically the `gruvbox8_hard` variant.

Then add the following to your `.vimrc`:

```
source ~/dotfiles/config.vim
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

Then in tmux, install plugins with `<prefix> - I`.

## Configure gnome-terminal

Install the [Hack font](https://github.com/source-foundry/Hack).

Apply the gruvbox8 theme using
[gnome-terminal-configure](https://github.com/letitz/gnome-terminal-configure).
