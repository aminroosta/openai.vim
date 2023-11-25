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
    stream = true,
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
  local streamed = ""
  local callback = function(_, line)
    chunk = chunk .. line

    local chunk_cleaned = string.gsub(chunk, "^data: ", "")
    local ok, result = pcall(vim.json.decode, chunk_cleaned)


    if (ok) then
      local scontent = result.choices[1].delta.content
      local finish_reason = result.choices[1].delta.finish_reason

      if (type(scontent) ~= "string") then
        return
      end

      streamed = streamed .. scontent

      local lines = M.split(streamed, "\n")

      vim.schedule(function()
        vim.api.nvim_buf_set_lines(buf, line1, line1 + #lines, false, lines)
      end)
      chunk = ""
    end
  end

  M.post("gpt-3.5-turbo", messages, callback)
end

function M.openai(line1, line2, command)
  if (command == "list") then
    Menu.menu(M.commands, function(key)
      M.rewrite(line1, line2, key)
    end)
  else
    M.rewrite(line1, line2, command)
  end
end

return M
