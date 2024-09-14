local Popup = require("nui.popup")
local Layout = require("nui.layout")
local Input = require("nui.input")
local event = require("nui.utils.autocmd").event

local M = {}

function M.ask(on_submit)
  local popup_one = Input({
    enter = true,
    position = "50%",
    size = { width = 20 },
    border = {
      style = "single",
      text = {
        top = "[What would you like to change?]",
        top_align = "left",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:Normal",
    },
  }, {
    prompt = "> ",
    default_value = "",
    on_close = function() end,
    on_submit = function(question)
      on_submit(question)
    end,
  })
  local popup_two = Popup({
    border = "single",
  })

  local layout = Layout(
    {
      position = "50%",
      size = {
        width = 80,
        height = "60%",
      },
    },
    Layout.Box({
      Layout.Box(popup_one, { size = "40%" }),
      Layout.Box(popup_two, { size = "60%" }),
    }, { dir = "col" })
  )

  popup_one:map("n", "q", function() layout:unmount() end)
  popup_two:map("n", "q", function() layout:unmount() end)
  popup_one:map("n", "<ESC>", function() layout:unmount() end)
  popup_two:map("n", "<ESC>", function() layout:unmount() end)

  popup_one:map("n", "r", function()
    layout:update(Layout.Box({
      Layout.Box(popup_one, { size = "40%" }),
      Layout.Box(popup_two, { size = "60%" }),
    }, { dir = "row" }))
  end, {})

  popup_one:on(event.BufLeave, function()
    layout:unmount()
  end)

  layout:mount()
end

return M
