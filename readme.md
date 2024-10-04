## openai.vim

A Neovim plugin that exposes OpenAI’s Chat Completion API.

## Installation
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

#### Installation Ollama
1. Install [ollama](https://ollama.com/download) and pull a model to be used: `ollama pull llama3.2`
2. Export the following variables to your `~/.bashrc`
```bash
export OPENAI_API_KEY=''
export OPENAI_CHAT_MODEL='llama3.2'
export OPENAI_ENDPOINT='http://127.0.0.1:11434/api/chat'
```
#### Installation OpenAI
1. Add your `OPENAI_API_KEY` to the environment variables by running the following command in the terminal:
```bash
export OPENAI_API_KEY='your-api-key-goes-here'
export OPENAI_CHAT_MODEL='gpt-4o-mini'
```
#### Installation LMStudio
1. Install [lmstudio](https://lmstudio.ai/), and download a model to be used: `lmstudio-community/Llama-3.2-3B-Instruct-GGUF`.
2. Start the server from the "Local Server" tab in the app.
3. Export the following variables to your `~/.bashrc`
```bash
export OPENAI_API_KEY=''
export OPENAI_CHAT_MODEL='lmstudio-community/Llama-3.2-3B-Instruct-GGUF'
export OPENAI_ENDPOINT='http://127.0.0.1:1234/v1/chat/completions'
```

## Configuration using JSON
To customize your commands, create or modify the `~/.config/nvim/commands.json` file. This file should contain your command configurations in JSON format.  
For information on structuring your commands, refer to OpenAI's [Chat Completion API](https://platform.openai.com/docs/guides/text-generation/chat-completions-api) documentation.

Here is an example, the `TEXT` keyword is replaced by the visual selection in vim.
```json
{
  "ask": [
    {
      "role": "user",
      "content": "TEXT"
    }
  ],
  "jsdoc": [
    {
      "role": "user",
      "content": "Convert this to JSDoc format:\nTEXT"
    }
  ],
  "rewrite": [
    {
      "role": "user",
      "content": "Fix grammatical mistakes and reorder sentences if needed:\n\nTEXT"
    }
  ],
  "eng": [
    {
      "role": "user",
      "content": "Rewrite this in natural english:\n\nTEXT"
    }
  ]
}
```

## Usage

The plugin exposes a visual mode command `:Openai` that takes an argument, the special argument `list` shows a popup.

```vim
:'<,'>Openai list
```

The first argument references the key in your `~/.config/nvim/commands.json` file.

```vim
:'<,'>Openai ask
:'<,'>Openai jsdoc
:'<,'>Openai rewrite
:'<,'>Openai eng
```

## Configuration using yaml
If you find `.yaml` files easier to modify and maintain, create `~/.config/nvim/commands.yml` file, and manually convert it to json.

```yaml
# cat ~/.config/nvim/commands.yml | yq -o json > ~/.config/nvim/commands.json
jsdoc:
  - role: "user"
    content: "Convert this to JSDoc format:\nTEXT"
ask:
  - role: "user"
    content: "TEXT"
rewrite:
  - role: "user"
    content: "Fix grammatical mistakes and reorder sentences if needed:\n\nTEXT"
eng:
  - role: "user"
    content: "Rewrite this in natural english:\n\nTEXT"
```

You'd need to `brew install yq` for that conversion to work.
