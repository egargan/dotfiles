-- Filesystem explorer

function setup()
  local opts = { noremap = true, silent = true }

  require("nvim-tree").setup({
    renderer = {
      special_files = {},
      add_trailing = true,
      indent_markers = {
        enable = true,
        inline_arrows = true,
        icons = {
          corner = "│",
        },
      },
      icons = {
        symlink_arrow = " → ",
        git_placement = "before",
        padding = " ",
        show = {
          file = false,
          folder = false,
          folder_arrow = true,
          git = true,
          modified = false,
        },
        glyphs = {
          bookmark = "*",
          folder = {
            arrow_closed = "▸",
            arrow_open = "▾",
          },
          git = {
            unstaged = "w",
            staged = "s",
            unmerged = "u",
            renamed = "m",
            untracked = "n",
            deleted = "d",
            ignored = "i",
          },
        },
      }
    },
  })

  vim.keymap.set('n', '<leader>e', function() vim.cmd('NvimTreeToggle') end, opts)
  vim.keymap.set('n', '<leader>5', function() vim.cmd('NvimTreeFindFile') end, opts)
end

return {
  name = 'nvim-tree/nvim-tree.lua',
  setup = setup,
}
