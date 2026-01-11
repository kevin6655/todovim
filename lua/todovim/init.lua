local M = {}

-- デフォルト設定
M.config = {
  -- TODO マーカーのパターン
  patterns = {
    "TODO",
    "FIXME",
    "HACK",
    "NOTE",
    "WARNING",
    "XXX",
    "BUG",
  },
  -- 除外するディレクトリ
  exclude_dirs = {
    ".git",
    "node_modules",
    ".cache",
    "dist",
    "build",
  },
  -- 検索するファイル拡張子 (空の場合はすべて)
  file_extensions = {},
  -- ウィンドウの設定
  window = {
    width = 80,
    height = 20,
    border = "rounded",
  },
}

-- TODO アイテムの構造
-- {
--   file = "path/to/file",
--   line = 10,
--   col = 5,
--   type = "TODO",
--   text = "実装する必要がある",
-- }

-- 設定を更新
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

-- ファイルから TODO を抽出
function M.extract_todos_from_file(filepath)
  local todos = {}
  local file = io.open(filepath, "r")

  if not file then
    return todos
  end

  local line_num = 0
  for line in file:lines() do
    line_num = line_num + 1

    for _, pattern in ipairs(M.config.patterns) do
      -- コメント内の TODO パターンを検索
      -- line:find() の返り値: start_pos, end_pos, capture1, capture2, capture3, ...
      local start_pos, end_pos, prefix, todo_type, text = line:find("(.-)(" .. pattern .. ")%s*:?%s*(.*)")

      if todo_type then
        table.insert(todos, {
          file = filepath,
          line = line_num,
          col = start_pos or 1,
          type = todo_type,
          text = text or "",
          full_line = line:gsub("^%s+", ""), -- 先頭の空白を削除
        })
        break
      end
    end
  end

  file:close()
  return todos
end

-- ディレクトリを除外すべきか判定
local function should_exclude_dir(dir)
  for _, exclude in ipairs(M.config.exclude_dirs) do
    if dir:match(exclude) then
      return true
    end
  end
  return false
end

-- ファイル拡張子をチェック
local function should_include_file(filepath)
  if #M.config.file_extensions == 0 then
    return true
  end

  for _, ext in ipairs(M.config.file_extensions) do
    if filepath:match("%." .. ext .. "$") then
      return true
    end
  end
  return false
end

-- プロジェクト全体から TODO を抽出
function M.extract_all_todos(search_path)
  local todos = {}
  search_path = search_path or vim.fn.getcwd()

  -- find コマンドで全ファイルを取得
  local exclude_pattern = ""
  for _, dir in ipairs(M.config.exclude_dirs) do
    exclude_pattern = exclude_pattern .. " -not -path '*/" .. dir .. "/*'"
  end

  local cmd = string.format("find %s -type f %s 2>/dev/null", search_path, exclude_pattern)
  local handle = io.popen(cmd)

  if not handle then
    return todos
  end

  for filepath in handle:lines() do
    if should_include_file(filepath) then
      local file_todos = M.extract_todos_from_file(filepath)
      for _, todo in ipairs(file_todos) do
        table.insert(todos, todo)
      end
    end
  end

  handle:close()
  return todos
end

-- 現在のバッファから TODO を抽出
function M.extract_todos_from_current_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  local todos = {}

  for line_num, line in ipairs(lines) do
    for _, pattern in ipairs(M.config.patterns) do
      -- line:find() の返り値: start_pos, end_pos, capture1, capture2, capture3, ...
      local start_pos, end_pos, prefix, todo_type, text = line:find("(.-)(" .. pattern .. ")%s*:?%s*(.*)")

      if todo_type then
        table.insert(todos, {
          file = filepath,
          line = line_num,
          col = start_pos or 1,
          type = todo_type,
          text = text or "",
          full_line = line:gsub("^%s+", ""),
        })
        break
      end
    end
  end

  return todos
end

return M
