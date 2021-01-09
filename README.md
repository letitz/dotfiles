# Setup

First, clone this repository into `~/dotfiles`.

## Configure bash

Add the following to your .bashrc:

```sh
# Better prompt.
source ~/dotfiles/prompt.sh
```

## Configure vim

Install the jellybeans colorscheme, either by downloading `jellybeans.vim` into
`.vim/colors/`, or by installing a plugin manager and using it to install
jellybeans.

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

## Configure gnome-terminal

Run the following command:

```sh
$ ~/dotfiles/style-gnome-terminal.sh gruvbox8
```
