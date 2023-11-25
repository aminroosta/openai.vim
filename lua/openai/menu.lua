local Menu = require("nui.menu")
local _event = require("nui.utils.autocmd").event

local M = {}

function M.menu(commands, on_submit)
  local lines = {}
  for key, value in pairs(commands) do
    table.insert(lines, Menu.item(key))
  end

  local menu = Menu({
    position = "50%",
    size = {
      width = 25,
      height = 5,
    },
    border = {
      style = "single",
      text = {
        top = "[Choose-an-Element]",
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:Normal",
    },
  }, {
    lines = lines,
    max_width = 20,
    keymap = {
      focus_next = { "j", "<Down>", "<Tab>" },
      focus_prev = { "k", "<Up>", "<S-Tab>" },
      close = { "<Esc>", "<C-c>" },
      submit = { "<CR>", "<Space>" },
    },
    -- on_close = function()
    --   print("Menu Closed!")
    -- end,
    on_submit = function(item)
      on_submit(item.text)
    end,
  })

  menu:mount()
end

return M
