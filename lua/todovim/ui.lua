local M = {}

local todovim = require("todovim")

-- ウィンドウとバッファの状態
local state = {
  buf = nil,
  win = nil,
  todos = {},
}

-- バッファが有効かチェック
local function is_valid_buffer(bufnr)
  return bufnr and vim.api.nvim_buf_is_valid(bufnr)
end

-- ウィンドウが有効かチェック
local function is_valid_window(winid)
  return winid and vim.api.nvim_win_is_valid(winid)
end

-- TODO リストウィンドウを閉じる
function M.close()
  if is_valid_window(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
end

-- TODO の場所にジャンプ
local function jump_to_todo()
  local line = vim.api.nvim_win_get_cursor(state.win)[1]

  -- ヘッダー行をスキップ (最初の2行)
  if line <= 2 then
    return
  end

  local todo_index = line - 2
  local todo = state.todos[todo_index]

  if not todo then
    return
  end

  -- ウィンドウを閉じる
  M.close()

  -- ファイルに対応するバッファを探す
  local target_buf = vim.fn.bufnr(todo.file)

  if target_buf ~= -1 then
    -- バッファが既に存在する場合は切り替える
    vim.api.nvim_set_current_buf(target_buf)
  else
    -- バッファが存在しない場合
    -- 現在のバッファに未保存の変更があるかチェック
    local current_buf = vim.api.nvim_get_current_buf()
    local modified = vim.api.nvim_buf_get_option(current_buf, "modified")

    if modified then
      -- 未保存の変更がある場合は新しいウィンドウで開く
      vim.cmd("split " .. vim.fn.fnameescape(todo.file))
    else
      -- 未保存の変更がない場合は現在のウィンドウで開く
      vim.cmd("edit " .. vim.fn.fnameescape(todo.file))
    end
  end

  -- 行にジャンプ
  vim.api.nvim_win_set_cursor(0, { todo.line, todo.col - 1 })

  -- 画面中央に表示
  vim.cmd("normal! zz")
end

-- TODO リストを表示するバッファを作成
local function create_buffer(todos)
  local buf = vim.api.nvim_create_buf(false, true)

  -- バッファオプションを設定
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  vim.api.nvim_buf_set_option(buf, "filetype", "todovim")
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

  -- バッファ内容を作成
  local lines = {
    string.format("TODO List (%d items)", #todos),
    string.rep("─", 80),
  }

  for _, todo in ipairs(todos) do
    local file_short = vim.fn.fnamemodify(todo.file, ":~:.")
    local line_text = string.format(
      "[%s] %s:%d - %s",
      todo.type,
      file_short,
      todo.line,
      todo.text
    )
    table.insert(lines, line_text)
  end

  if #todos == 0 then
    table.insert(lines, "No TODOs found!")
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  -- キーマッピングを設定
  local opts = { noremap = true, silent = true, buffer = buf }
  vim.keymap.set("n", "<CR>", jump_to_todo, opts)
  vim.keymap.set("n", "q", M.close, opts)
  vim.keymap.set("n", "<ESC>", M.close, opts)

  return buf
end

-- フローティングウィンドウを作成
local function create_window(buf)
  local width = todovim.config.window.width
  local height = todovim.config.window.height

  -- エディタのサイズを取得
  local ui = vim.api.nvim_list_uis()[1]
  local editor_width = ui.width
  local editor_height = ui.height

  -- ウィンドウを中央に配置
  local col = math.floor((editor_width - width) / 2)
  local row = math.floor((editor_height - height) / 2)

  local opts = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = todovim.config.window.border,
  }

  local win = vim.api.nvim_open_win(buf, true, opts)

  -- ウィンドウオプションを設定
  vim.api.nvim_win_set_option(win, "cursorline", true)
  vim.api.nvim_win_set_option(win, "number", false)
  vim.api.nvim_win_set_option(win, "relativenumber", false)

  return win
end

-- TODO リストを表示
function M.show_todos(todos)
  -- 既存のウィンドウを閉じる
  if is_valid_window(state.win) then
    M.close()
  end

  -- TODO リストを保存
  state.todos = todos

  -- バッファとウィンドウを作成
  state.buf = create_buffer(todos)
  state.win = create_window(state.buf)

  -- カーソルを最初のTODOに移動 (ヘッダーの次の行)
  if #todos > 0 then
    vim.api.nvim_win_set_cursor(state.win, { 3, 0 })
  end
end

-- プロジェクト全体の TODO を表示
function M.show_all_todos()
  local todos = todovim.extract_all_todos()
  M.show_todos(todos)
end

-- 現在のバッファの TODO を表示
function M.show_buffer_todos()
  local todos = todovim.extract_todos_from_current_buffer()
  M.show_todos(todos)
end

-- トグル機能
function M.toggle()
  if is_valid_window(state.win) then
    M.close()
  else
    M.show_all_todos()
  end
end

return M
