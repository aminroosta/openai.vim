local Input = require("nui.input")
local event = require("nui.utils.autocmd").event

local M = {}

function M.ask(callback, initial_text)
  if initial_text ~= "" then
    initial_text = initial_text .. " "
  end
  local input = Input({
    enter = true,
    position = "10%",
    size = { width = "90%", height = 4 },
    border = {
      style = "single",
      text = {
        top = "[What would you like to change?]",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:Normal",
    },
  }, {
    prompt = "> ",
    default_value = initial_text,
    on_close = function() end,
    on_submit = function(question)
      callback(question)
    end,
  })

  input:map("n", "q", function() input:unmount() end)
  input:map("i", "<ESC>", function() input:unmount() end)
  input:map("n", "<ESC>", function() input:unmount() end)


  input:on(event.BufLeave, function()
    input:unmount()
  end)

  input:mount()
end

return M
