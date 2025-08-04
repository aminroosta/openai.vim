## openai.nvim

A Neovim plugin for AI-assisted code completion. It supports multiple providers and offers easy configuration.

## Installation (Lazy.nvim)
```lua
-- ~/.config/nvim/lua/plugins/openai.lua
return {
  "aminroosta/openai.vim",
  enabled = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  init = function()
    local keymap = vim.api.nvim_set_keymap
    keymap("v", "<cr>", ":Openai ask<cr>", { noremap = true })
    keymap("n", "<c-cr>", ":Openai ask /e<cr>", { noremap = true })
  end,
  opts = {
    api_key = os.getenv("OPENAI_API_KEY"),
    endpoint = "https://api.openai.com/v1/chat/completions",
    model = "gpt-4.1-mini",
    commands = "~/.config/nvim/commands.json"
  },
}
```

## Commands
<details> <summary>Copy this to `~/.config/nvim/commands.json`: </summary>

```json
{
  "ask": [
    {
      "role": "user",
      "content": "QUESTION\n\nTEXT\n"
    }
  ],
  "e": [
    {
      "role": "system",
      "content": "you are a code completion tool."
    },
    {
      "role": "user",
      "content": "task: QUESTION\n```NVIM_FILETYPE\nNVIM_BUFFER_WITH_CURSOR\n```\n- <CURSOR> is the cursor position.\n- NEVER reply anything but the added code.\n"
    }
  ],
  "t": [
    {
      "role": "user",
      "content": "Implement the TODO and only return the added code.\n```NVIM_FILETYPE\nNVIM_BUFFER\n```\n"
    }
  ],
  "r": [
    {
      "role": "user",
      "content": "Fix punctuation and grammatical mistakes:\n\nTEXT\n"
    }
  ]
}
```

</details>

- `QUESTION` is what you type in the modal.
- `TEXT` is the selected text in visual mode.
- `markdown` is `vim.o.filetype`.
- `NVIM_BUFFER` is the content of the current buffer.
- `NVIM_BUFFER_WITH_CURSOR` is the content of the buffer with the cursor position marked with `<CURSOR>`.

# Providers

* Ollama

```lua
  opts = {
    api_key = "",
    endpoint = "http://127.0.0.1:11434/api/chat",
    model = "llama3.2",
    commands = "~/.config/nvim/commands.json"
  },
```


* OpenAI
```lua
  opts = {
    api_key = os.getenv("OPENAI_API_KEY"),
    endpoint = "https://api.openai.com/v1/chat/completions",
    model = "gpt-4.1-mini",
    commands = "~/.config/nvim/commands.json"
  },
```

* LMStudio
```lua
  opts = {
    api_key = "",
    endpoint = "http://127.0.0.1:1234/v1/chat/completions",
    model = "lmstudio-community/Llama-3.2-3B-Instruct-GGUF",
    commands = "~/.config/nvim/commands.json"
  },
```

## Configuration using yaml
Create `~/.config/nvim/commands.yml` file, and manually convert it to json.
````yaml
# cat ~/.config/nvim/commands.yml | yq -o json > ~/.config/nvim/commands.json
ask:
  - role: "user"
    content: |
      QUESTION

      TEXT
e:
  - role: "system"
    content: you are a code completion tool.
  - role: "user"
    content: |
      task: QUESTION
      ```NVIM_FILETYPE
      NVIM_BUFFER_WITH_CURSOR
      ```
      - <CURSOR> is the cursor position.
      - NEVER reply anything but the added code.
      
t:
  - role: "user"
    content: |
      Implement the TODO and only return the added code.
      ```NVIM_FILETYPE
      NVIM_BUFFER
      ```
r:
  - role: "system"
    content: NEVER reply anything but the updated text.
  - role: "user"
    content: |
      Fix punctuation and grammatical mistakes:
      
      TEXT
````

`yq` is required for conversion, `brew install yq`.
