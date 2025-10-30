-- For some reason, using the lua-native `vim.opt.rtp:prepend()` function does
-- not work. The runtime path is set correctly, but plugins are not loaded from
-- the prepended directory.
vim.cmd("set runtimepath^=~/code/dotfiles/vim")

require("config.lazy")
