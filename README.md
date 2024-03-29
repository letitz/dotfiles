# Setup

First, clone this repository into `~/dotfiles`.

If your terminal does not support true colors, but supports 256 colors (as is
for example the case with mosh 1.3.2), switch to the `lesscolors` branch:

```sh
$ git switch lesscolors
```

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
