local Menu = require("openai.menu")
local Ask = require("openai.ask")
local curl = require("plenary.curl")

local OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
local OPENAI_ENDPOINT = os.getenv("OPENAI_ENDPOINT") or "https://api.openai.com"
local OPENAI_CHAT_MODEL = os.getenv("OPENAI_CHAT_MODEL") or "gpt-4o-mini"

local M = {}

function M.read_file(file)
  local filepath = vim.fn.expand(file)
  local f = io.open(filepath, "rb")

  if not f then
    local message = "File Not Found: " .. filepath
    vim.notify(message, vim.log.levels.WARN)
    return "{}"
  end

  local content = f:read("*all")
  f:close()
  return content
end

M.commands = vim.json.decode(M.read_file("~/.config/nvim/commands.json"))

function M.post(messages, on_stdout)
  local data = vim.json.encode({
    model = OPENAI_CHAT_MODEL,
    messages = messages,
    stream = true,
  })
  return curl.post(OPENAI_ENDPOINT .. "/v1/chat/completions", {
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

function M.rewrite(line1, line2, messages, process)
  process = process or function(v) return v; end
  local buf = vim.api.nvim_get_current_buf()

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

      streamed = process(streamed .. scontent)

      local lines = M.split(streamed, "\n")

      vim.schedule(function()
        vim.api.nvim_buf_set_lines(buf, line1, line1 + #lines, false, lines)
      end)
      chunk = ""
    end
  end

  M.post(messages, callback)
end

function M.read_text(line1, line2)
  local buf = vim.api.nvim_get_current_buf()
  local input_lines = vim.api.nvim_buf_get_lines(buf, line1, line2, false)
  local text = table.concat(input_lines, "\n")

  return text
end

function M.run_command(line1, line2, key)
  local command = M.commands[key]
  local text = M.read_text(line1, line2)

  local messages = {}
  for _, value in ipairs(command) do
    local content = string.gsub(value.content, "TEXT", text)
    table.insert(messages, {
      role = value.role,
      content = content
    })
  end

  M.rewrite(line1, line2, messages)
end

function M.openai(line1, line2, command)
  line1 = line1 - 1
  if (command == "list") then
    Menu.menu(M.commands, function(key)
      M.run_command(line1, line2, key)
    end)
  elseif (command == "ask") then
    Ask.ask(function(question)
      local text = M.read_text(line1, line2)
      M.rewrite(line1, line2, {
        {
          role = "user",
          content = question .. "\n\n" .. text
        }
      }, function(streamed)
        return string.gsub(streamed, "```", "")
      end);
    end)
  else
    M.run_command(line1, line2, command)
  end
end

return M
