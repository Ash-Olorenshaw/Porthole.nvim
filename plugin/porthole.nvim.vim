" Title:        Porthole.nvim
" Description:  Provides a little popup filetree to easily get a small but quick idea of the project overview.
" Last Change:  17 December 2024
" Maintainer:   Ash Olorenshaw <https://github.com/ash-olorenshaw>

" Prevents the plugin from being loaded multiple times. If the loaded
" variable exists, do nothing more. Otherwise, assign the loaded
" variable and continue running this instance of the plugin.
if exists("g:loaded_portholenvim")
    finish
endif
let g:loaded_portholenvim = 1

" Exposes the plugin's functions for use as commands in Neovim.
command! -nargs=0 WindowFloat lua require("porthole-nvim").create_floating_window()
