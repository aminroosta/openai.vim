" Title:        Confluence Plugin for Neovim
" Description:  A plugin to navigate and edit Confluence pages in Neovim.
" Maintainer:   Amin Roosta <https://github.com/aminroosta>

" Prevents the plugin from being loaded multiple times. If the loaded
" variable exists, do nothing more. Otherwise, assign the loaded
" variable and continue running this instance of the plugin.
if exists("g:loaded_confluenceplugin")
    finish
endif

let g:loaded_confluenceplugin = 1

" Defines a package path for Lua. This facilitates importing the
" Lua modules from the plugin's dependency directory.
let s:lua_deps_loc =  expand("<sfile>:h:r") . "/../lua/confluence/deps"
exe "lua package.path = package.path .. ';" . s:lua_deps_loc . "/lua-?/init.lua'"

" Exposes the plugin's functions for use as commands in Neovim.
command! -nargs=1 Echo lua require("confluence").echo(vim.fn.expand("<args>"))
