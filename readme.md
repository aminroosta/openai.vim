## openai.vim

A Neovim plugin that exposes OpenAI’s Chat Completion API.

### Installation

1. Add your `OPENAI_API_KEY` to the environment variables by running the following command in the terminal:
```bash
echo 'export OPENAI_API_KEY=your-openai-key' >> ~/.bashrc
echo 'export OPENAI_CHAT_MODEL=gpt-4o-mini' >> ~/.bashrc
```

2. (Optional) If you are using an opensource LLM via [lmstudio](https://lmstudio.ai/), you can export `OPENAI_ENDPOINT` by running these commands in the terminal:
```bash
echo 'export OPENAI_API_KEY' >> ~/.bashrc
echo 'export OPENAI_CHAT_MODEL=llama3.1:8b' >> ~/.bashrc
echo 'export OPENAI_ENDPOINT=http://192.168.2.20:1234' >> ~/.bashrc
```

3. Using [packer.nvim](https://github.com/wbthomason/packer.nvim), add the following code to your `init.lua` file:
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
To customize your commands, create or modify the `~/.config/nvim/commands.json` file. This file should contain your command configurations in JSON format.  
For information on structuring your commands, refer to OpenAI's [Chat Completion API](https://platform.openai.com/docs/guides/text-generation/chat-completions-api) documentation.

For example, to add a command that generates a summary of the input text, your `commands.json` file should look like this:
```json
{
  "summary": [
    {
      "role": "user",
      "content": "Write a summary of the following text:\n\nTEXT"
    }
  ]
}
```

### Usage

The plugin exposes a visual mode command `:Openai` that shows a popup with the configured commands.

```vim
:'<,'>Openai list
```

If an argument is provided, the popup menu will be skipped.

```vim
:'<,'>Openai summary
```

There is also support for a builtin `ask` command which opens a popup for you type in your question.

```vim
:'<,'>Openai ask
```
