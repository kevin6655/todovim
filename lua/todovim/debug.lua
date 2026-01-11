-- デバッグ用のヘルパー関数

local M = {}

-- パターンマッチングのテスト
function M.test_pattern()
  local test_line = "-- TODO: これはテストのTODOコメントです"
  local pattern = "TODO"

  print("Test line: " .. test_line)
  print("Pattern: " .. pattern)

  local start_pos, end_pos, prefix, todo_type, text = test_line:find("(.-)(" .. pattern .. ")%s*:?%s*(.*)")

  if todo_type then
    print("Match found!")
    print("  start_pos: " .. tostring(start_pos))
    print("  end_pos: " .. tostring(end_pos))
    print("  prefix: '" .. tostring(prefix) .. "'")
    print("  todo_type: '" .. tostring(todo_type) .. "'")
    print("  text: '" .. tostring(text) .. "'")
  else
    print("No match found")
  end
end

-- 現在のバッファから抽出したTODOを表示
function M.show_extracted_todos()
  local todovim = require("todovim")
  local todos = todovim.extract_todos_from_current_buffer()

  print("\n=== Extracted TODOs ===")
  print("Total: " .. #todos)

  for i, todo in ipairs(todos) do
    print(string.format("\nTODO #%d:", i))
    print("  file: " .. todo.file)
    print("  line: " .. todo.line)
    print("  col: " .. todo.col)
    print("  type: '" .. todo.type .. "'")
    print("  text: '" .. todo.text .. "'")
    print("  full_line: '" .. todo.full_line .. "'")
  end
end

return M
