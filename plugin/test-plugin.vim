" Title:        Example Plugin
" Description:  A plugin to provide an example for creating Neovim plugins.
" Last Change:  8 November 2021
" Maintainer:   Example User <https://github.com/example-user>

" Prevents the plugin from being loaded multiple times. If the loaded
" variable exists, do nothing more. Otherwise, assign the loaded
" variable and continue running this instance of the plugin.
if exists("g:loaded_testplugin")
    finish
endif
let g:loaded_testplugin = 1

" Exposes the plugin's functions for use as commands in Neovim.
command! -nargs=0 WindowFloat lua require("test-plugin").create_floating_window()
