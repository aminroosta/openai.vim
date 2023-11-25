## openai.vim

A Neovim plugin that exposes OpenAI’s Chat Completion API.

### Installation

Add your `OPENAI_API_KEY` to your environment variables.
```bash
echo 'export OPENAI_API_KEY' >> ~/.bashrc
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim), add this to your init.lua:
```lua
require('packer').startup(function()
  use {
    "aminroosta/openai.vim",
    requires = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    }
  }
end)
```


### Configuration
Add your own commands by modifying `require("openai").commands` table in your init.lua.  
see openai's [Chat Completion API](https://platform.openai.com/docs/guides/text-generation/chat-completions-api) documentation for more info.

For example, to add a command that generates a summary of the input text, you can do:
```lua
-- TEXT will be replaced with the selected text
require("openai").commands = {
  Summary = {
    {
      role = "user",
      content = "Write a summary of the following text:\n\nTEXT"
    }
  },
}
```

```
### Usage

The plugin exposes a visual mode command `:Openai` that shows a popup with configured commands.

```vim
:'<,'>Openai
```

If an argument is given, the popup menu will be skipped.

```vim
:'<,'>Openai Summary
```

