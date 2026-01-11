# todovim

Neovim用のTODOリスト表示プラグイン。プロジェクト内のコメントから`TODO`、`FIXME`、`HACK`などのマーカーを抽出して、フローティングウィンドウに一覧表示します。

## 特徴

- プロジェクト全体またはカレントバッファからTODOを抽出
- フローティングウィンドウでTODOを一覧表示
- Enterキーで該当箇所にジャンプ
- カスタマイズ可能なマーカーパターン
- lazy.nvim完全対応

## インストール

### lazy.nvim

```lua
{
  "kevin6655/todovim",
  cmd = { "TodoShow", "TodoShowBuffer", "TodoToggle", "TodoClose" },
  keys = {
    { "<leader>td", "<cmd>TodoToggle<cr>", desc = "Toggle TODO list" },
    { "<leader>tb", "<cmd>TodoShowBuffer<cr>", desc = "Show buffer TODOs" },
  },
  opts = {
    -- デフォルト設定（オプション）
    patterns = {
      "TODO",
      "FIXME",
      "HACK",
      "NOTE",
      "WARNING",
      "XXX",
      "BUG",
    },
    exclude_dirs = {
      ".git",
      "node_modules",
      ".cache",
      "dist",
      "build",
    },
    window = {
      width = 80,
      height = 20,
      border = "rounded",
    },
  },
}
```

### lazy.nvim（pluginsディレクトリを使用）

`~/.config/nvim/lua/plugins/todovim.lua` を作成：

```lua
return {
  "kevin6655/todovim",
  cmd = { "TodoShow", "TodoShowBuffer", "TodoToggle", "TodoClose" },
  keys = {
    { "<leader>td", "<cmd>TodoToggle<cr>", desc = "Toggle TODO list" },
    { "<leader>tb", "<cmd>TodoShowBuffer<cr>", desc = "Show buffer TODOs" },
  },
  opts = {
    -- デフォルト設定（オプション）
    patterns = {
      "TODO",
      "FIXME",
      "HACK",
      "NOTE",
      "WARNING",
      "XXX",
      "BUG",
    },
    exclude_dirs = {
      ".git",
      "node_modules",
      ".cache",
      "dist",
      "build",
    },
    window = {
      width = 80,
      height = 20,
      border = "rounded",
    },
  },
}
```

この方法を使用する場合、`~/.config/nvim/init.lua` に以下の設定が必要です：

```lua
require("lazy").setup("plugins")
```

### Packer

```lua
use {
  "kevin6655/todovim",
  config = function()
    require("todovim").setup({
      -- 設定オプション（オプション）
    })
  end
}
```

## 使い方

### コマンド

- `:TodoShow` - プロジェクト全体のTODOを表示
- `:TodoShowBuffer` - 現在のバッファのTODOを表示
- `:TodoToggle` - TODOリストウィンドウの表示/非表示を切り替え
- `:TodoClose` - TODOリストウィンドウを閉じる

### キーマップ（TODOウィンドウ内）

- `<CR>` (Enter) - 選択したTODOの場所にジャンプ
- `q` - ウィンドウを閉じる
- `<ESC>` - ウィンドウを閉じる

### 推奨キーマップ

```lua
vim.keymap.set("n", "<leader>td", "<cmd>TodoToggle<cr>", { desc = "Toggle TODO list" })
vim.keymap.set("n", "<leader>tb", "<cmd>TodoShowBuffer<cr>", { desc = "Show buffer TODOs" })
```

## 設定

```lua
require("todovim").setup({
  -- 検索するTODOマーカー
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

  -- 特定の拡張子のみ検索する場合（空の場合はすべて）
  file_extensions = {}, -- 例: { "lua", "js", "py" }

  -- ウィンドウの設定
  window = {
    width = 80,
    height = 20,
    border = "rounded", -- "none", "single", "double", "rounded", "solid", "shadow"
  },
})
```

## 使用例

コード内にTODOコメントを書く：

```lua
-- TODO: この関数を最適化する
function example()
  -- FIXME: バグを修正する必要がある
  print("Hello")
end
```

```python
# TODO: エラーハンドリングを追加
def process_data():
    # NOTE: この部分は後で見直す
    pass
```

`:TodoShow`を実行すると、フローティングウィンドウにTODOリストが表示されます。

## ライセンス

MIT License
