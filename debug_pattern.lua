-- パターンマッチングのデバッグスクリプト

local test_lines = {
  "-- TODO: これはテストのTODOコメントです",
  "-- FIXME: バグを修正する必要があります",
  "  -- NOTE: 重要な注記事項",
  "# TODO: Pythonスタイルのコメント",
  "// TODO: C++スタイルのコメント",
}

local patterns = { "TODO", "FIXME", "NOTE" }

print("=== パターンマッチングテスト ===\n")

for _, line in ipairs(test_lines) do
  print("Line: " .. line)

  for _, pattern in ipairs(patterns) do
    local start_pos, end_pos, prefix, todo_type, text = line:find("(.-)(" .. pattern .. ")%s*:?%s*(.*)")

    if todo_type then
      print(string.format("  パターン: %s", pattern))
      print(string.format("  start_pos: %d, end_pos: %d", start_pos, end_pos))
      print(string.format("  prefix: '%s'", prefix))
      print(string.format("  todo_type: '%s'", todo_type))
      print(string.format("  text: '%s'", text))
      break
    end
  end
  print()
end
