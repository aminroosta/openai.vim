local Menu = require("openai.menu")


local M = {}

M.commands = {
  Summary = {
    {
      role = "user",
      content = "Write a summary of the following text:\n\nTEXT"
    }
  },
}

local OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

local curl = require("plenary.curl")

function M.post(model, messages, on_stdout)
  local data = vim.json.encode({
    model = model,
    messages = messages,
  })
  return curl.post("https://api.openai.com/v1/chat/completions", {
    stream = on_stdout,
    headers = {
      ["Authorization"] = "Bearer " .. OPENAI_API_KEY,
      ["Content-Type"] = "application/json"
    },
    body = data,
  })
end

function M.split(str, delimiter)
  local result               = {}
  local from                 = 1
  local delim_from, delim_to = string.find(str, delimiter, from)
  while delim_from do
    table.insert(result, string.sub(str, from, delim_from - 1))
    from                 = delim_to + 1
    delim_from, delim_to = string.find(str, delimiter, from)
  end
  table.insert(result, string.sub(str, from))
  return result
end

vim.cmd("highlight OpenaiHighlight gui=bold cterm=bold ctermbg=lightblue guibg=lightblue")
local ns_id = vim.api.nvim_create_namespace("openai")

function M.rewrite(line1, line2, key)
  line1 = line1 - 1
  local command = M.commands[key]
  local buf = vim.api.nvim_get_current_buf()
  local input_lines = vim.api.nvim_buf_get_lines(buf, line1, line2, false)
  local text = table.concat(input_lines, "\n")

  local messages = {}
  for _, value in ipairs(command) do
    local content = string.gsub(value.content, "TEXT", text)
    table.insert(messages, {
      role = value.role,
      content = content
    })
  end

  local chunk = ""
  local callback = function(_, line)
    chunk = chunk .. line
    local ok, result = pcall(vim.json.decode, chunk)

    if (ok) then
      local content = result.choices[1].message.content

      local lines = M.split(content, "\n")

      vim.schedule(function()
        vim.api.nvim_buf_set_lines(buf, line1, line1 + #lines + 1, false, lines)
        local ids = {}
        for idx, line in ipairs(lines) do
          local i = line1 + idx - 1
          local id = vim.api.nvim_buf_set_extmark(
            0, ns_id, i, 0,
            {
              end_row = i,
              end_col = string.len(line),
              hl_group = "OpenaiHighlight",
            })
          table.insert(ids, id)
        end
        vim.defer_fn(function()
          for _, id in ipairs(ids) do
            vim.api.nvim_buf_del_extmark(buf, ns_id, id)
          end
        end, 1500)
        line1 = line1 + #lines
      end)
      chunk = ""
    end
  end

  M.post("gpt-3.5-turbo", messages, callback)
end

function M.openai(line1, line2, command)
  if (command == nil) then
    Menu.menu(M.commands, function(key)
      M.rewrite(line1, line2, key)
    end)
  else
    M.rewrite(line1, line2, command)
  end
end

return M
