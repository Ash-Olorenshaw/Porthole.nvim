# Porthole.nvim

_A small, slightly rounded view into the files in your current directory._

## What is Porthole.nvim?

Porthole.nvim is a small plugin for NeoVim to give you a popup window to show you the current directory's files and folders.

Mostly written in Lua, Porthole also uses a small compiled F# .NET program to perform directory searches called [**Lister**](https://github.com/Ash-Olorenshaw/Lister). Don't have .NET installed? 
Don't worry about it, Porthole falls back to using Bash, Pwsh or CMD depending on your system (just a slight performance decrease).

### Features 
 - Small (screenspace-wise and storage-wise) and fast!
 - [NERDFont](https://github.com/ryanoasis/nerd-fonts) icons (can be turned off)
 - Interaction with folders, files, etc
 - Fully cross-platform
 - Customisable
 - Colourful!

![Porthole.nvim in action](/Screenshots/main.png?raw=true "Porthole.nvim")

## Getting Started

Get started by installing this plugin with your plugin manager of choice:

```Vim
" Vim-Plugged
Plug "ash-olorenshaw/porthole.nvim"
```

then run
```Vim
:Porthole
```
to get started!

If you want to have Porthole.nvim use [**Lister**](https://github.com/Ash-Olorenshaw/Lister) for better speeds - install .NET 8.0 with your method of choice.

e.g.
```nu-script
# Ubuntu
sudo apt update
sudo apt install dotnet8
```

## Settings

Below are the default settings for Porthole.nvim:
```lua
require "porthole-nvim".setup {
	width_ratio = 0.2,
	height_ratio = 0.2,
	quit_key = 'q',
	reload_key = 'r',
	action_key = '<CR>',
	use_icons = true
}
```
Put this either in your `init.lua` or in a Lua block in your `init.vim` if you want to tweak things.

When set to *true*, `use_icons` will use [NERDFont](https://github.com/ryanoasis/nerd-fonts) icons.

## Credits

Influences/other stuff that is similar:

 - [Telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
 - [NERDTree](https://github.com/preservim/nerdtree)
 - [Vim-Devicons](https://github.com/ryanoasis/vim-devicons)
 - [Nvim-Tree.lua](https://github.com/nvim-tree/nvim-tree.lua) - (one day *Porthole* might have all the features this incredible plugin has!)
