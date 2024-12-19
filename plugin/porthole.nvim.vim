" Porthole.nvim
" Provides a little popup filetree to easily get a small but quick idea of the project overview.
" Created & maintained by Ash Olorenshaw

if exists("g:loaded_portholenvim")
    finish
endif
let g:loaded_portholenvim = 1

command! -nargs=0 Porthole lua require("porthole-nvim").create_floating_window()
