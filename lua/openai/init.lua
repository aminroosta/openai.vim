local Menu = require("openai.menu")
local Ask = require("openai.ask")
local curl = require("plenary.curl")

local OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
local OPENAI_ENDPOINT = os.getenv("OPENAI_ENDPOINT") or "https://api.openai.com/v1/chat/completions"
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

function M.with_cursor(content)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local lines = M.split(content, "\n")
  local line_cursor = cursor[1]
  local col_cursor = cursor[2]

  if line_cursor > #lines then
    -- Cursor line is beyond content lines, append at the end
    lines[#lines + 1] = "<CURSOR>"
  else
    local target_line = lines[line_cursor]
    if col_cursor > #target_line then
      -- Cursor column beyond line length, append at end
      lines[line_cursor] = target_line .. "<CURSOR>"
    else
      -- Insert <CURSOR> at column (1-based)
      -- Note: Lua string indexing is 1-based; col_cursor is 0-based, so add 1
      local insert_pos = col_cursor
      lines[line_cursor] = target_line:sub(1, insert_pos) .. "<CURSOR>" .. target_line:sub(insert_pos + 1)
    end
  end
  return table.concat(lines, "\n")
end

M.commands = vim.json.decode(M.read_file("~/.config/nvim/commands.json"))

M.hl = vim.api.nvim_create_namespace("openai_vim_highlight")
-- vim.api.nvim_create_autocmd("InsertEnter", {
--   pattern = "*",
--   callback = function()
--     vim.api.nvim_buf_clear_namespace(0, M.hl, 0, -1)
--   end,
-- })
vim.api.nvim_create_autocmd({"CursorMoved" }, {
  pattern = "*",
  callback = function()
    vim.api.nvim_buf_clear_namespace(0, M.hl, 0, -1)
  end,
})

function M.post(messages, on_stdout)
  local data = vim.json.encode({
    model = OPENAI_CHAT_MODEL,
    messages = messages,
    stream = true,
  })

  return curl.post(OPENAI_ENDPOINT, {
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

function M.highlight(buf, line1, line2)
  vim.highlight.range(buf, M.hl, "Visual", { line1, 0 }, { line2 - 1, -1 })
end

function M.rewrite(line1, line2, messages)
  local buf = vim.api.nvim_get_current_buf()

  local current_line = line2
  local chunk = ""
  local streamed = ""
  local callback = function(_, line)
    chunk = chunk .. line

    -- openai has the extra "data:" prefix
    local chunk_cleaned = string.gsub(chunk, "^data: ", "")
    local ok, result = pcall(vim.json.decode, chunk_cleaned)

    if (ok) then
      local scontent = ''
      if (result.choices == nil) then -- ollama
        scontent = result.message.content
      else                            -- openai
        scontent = result.choices[1].delta.content
      end

      if (type(scontent) ~= "string") then
        return
      end

      streamed = streamed .. scontent

      local lines = M.split(streamed, "\n")
      local newLines = {}
      for _, row in ipairs(lines) do
        if not row:match("^```") then
          table.insert(newLines, row)
        end
      end

      vim.schedule(function()
        vim.api.nvim_buf_set_lines(buf, line2, current_line, false, newLines)
        current_line = line2 + #newLines
        M.highlight(buf, line2, current_line)
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

function M.read_buffer()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  return table.concat(lines, '\n')
end

function M.run_command(line1, line2, key, question)
  if (key == "list") then
    Menu.menu(M.commands, function(newKey)
      M.run_command(line1, line2, newKey)
    end)
  end
  if (key == "reload") then
    pcall(
      os.execute,
      "cat ~/.config/nvim/commands.yml | yq -o json > ~/.config/nvim/commands.json"
    )
    M.commands = vim.json.decode(M.read_file("~/.config/nvim/commands.json"))
    return
  end
  local command = M.commands[key]
  local text = M.read_text(line1, line2)
  local buf = M.read_buffer()
  local filetype = vim.bo.filetype

  local messages = {}
  for _, value in ipairs(command) do
    local content = string.gsub(value.content, "TEXT", text)
    content = string.gsub(content, "QUESTION", question)
    content = string.gsub(
      content,
      "NVIM_BUFFER_WITH_CURSOR",
      M.with_cursor(buf)
    )
    content = string.gsub(content, "NVIM_BUFFER", buf)
    content = string.gsub(content, "NVIM_FILETYPE", filetype)
    table.insert(messages, {
      role = value.role,
      content = content
    })
  end

  M.rewrite(line1, line2, messages)
end

function M.openai(line1, line2, args)
  local args_tbl = M.split(args, " ")
  local command = table.remove(args_tbl, 1)
  local subcommand = table.concat(args_tbl, " ")
  line1 = line1 - 1
  if (command == "ask") then
    Ask.ask(function(question)
      if string.sub(question, 1, 1) == "/" then
        local words = M.split(string.sub(question, 2), " ")
        local key = table.remove(words, 1)
        return M.run_command(line1, line2, key, table.concat(words, " "))
      end
      M.run_command(line1, line2, "ask", question)
    end, subcommand)
  else
    M.run_command(line1, line2, command, '')
  end
end

return M
