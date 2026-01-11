-- プラグインが既にロードされているかチェック
if vim.g.loaded_todovim then
  return
end
vim.g.loaded_todovim = true

local ui = require("todovim.ui")

-- コマンドを作成
vim.api.nvim_create_user_command("TodoShow", function()
  ui.show_all_todos()
end, { desc = "Show all TODOs in project" })

vim.api.nvim_create_user_command("TodoShowBuffer", function()
  ui.show_buffer_todos()
end, { desc = "Show TODOs in current buffer" })

vim.api.nvim_create_user_command("TodoToggle", function()
  ui.toggle()
end, { desc = "Toggle TODO list window" })

vim.api.nvim_create_user_command("TodoClose", function()
  ui.close()
end, { desc = "Close TODO list window" })
