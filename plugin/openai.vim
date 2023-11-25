" Title:        Openai Plugin for Neovim
" Description:  A plugin to run openai commands
" Maintainer:   Amin Roosta <https://github.com/aminroosta>

" Prevents the plugin from being loaded multiple times. If the loaded
" variable exists, do nothing more. Otherwise, assign the loaded
" variable and continue running this instance of the plugin.
if exists("g:loaded_openai_plugin")
    finish
endif

let g:loaded_openai_plugin = 1

" Defines a package path for Lua. This facilitates importing the
" Lua modules from the plugin's dependency directory.
let s:lua_deps_loc =  expand("<sfile>:h:r") . "/../lua/openai/deps"
exe "lua package.path = package.path .. ';" . s:lua_deps_loc . "/lua-?/init.lua'"

" Exposes the plugin's functions for use as commands in Neovim.
command! -range -nargs=1 Openai lua require("openai").openai(<line1>, <line2>, <f-args>)
