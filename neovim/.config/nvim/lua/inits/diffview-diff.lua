vim.g.mapleader = " "

vim.opt.number = true
vim.opt.syntax = 'on'
vim.opt.termguicolors = true
vim.opt.showtabline = 0 -- Hide tabline
vim.opt.laststatus = 3  -- Hide statusline
vim.opt.statusline = ' '

vim.api.nvim_set_keymap('n', 'q', ':qa!<Enter>', { noremap = true, silent = true })

-- 5-line up/down jumps
vim.api.nvim_set_keymap('', '<S-k>', '5k', { noremap = true })
vim.api.nvim_set_keymap('', '<S-j>', '5j', { noremap = true })

require('plugins.init')

local combined_plugin_spec = {
  {
    -- UIs for viewing git diffs, history, etc.
    'sindrets/diffview.nvim',

    -- lazy = false,
    opts = {
      enhanced_diff_hl = true,
      use_icons = false,
      icons = {
        folder_closed = "▸ ",
        folder_open = "▾ ",
      },
      signs = {
        fold_closed = "▸ ",
        fold_open = "▾ ",
        done = "✓",
      },
    },
    config = function(_, opts)
      require('diffview').setup(opts)

      -- Use hatching for 'empty' diff areas
      vim.opt.fillchars:append { diff = "╱" }
    end,
  }
}

-- Get only the treesitter plugin spec, and none of the complementary tools
local main_treesitter_spec = vim.tbl_filter(
  function(spec)
    return spec[1] == 'nvim-treesitter/nvim-treesitter'
  end,
  require('plugins.treesitter')
)

vim.list_extend(combined_plugin_spec, main_treesitter_spec)

vim.list_extend(combined_plugin_spec, require('plugins.nord'))

require("lazy").setup({
  spec = combined_plugin_spec,
})

local first_param = vim.v.argv[5]

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Set these after nord's done its thing
    vim.api.nvim_set_hl(0, "StatusLine", { fg = 'none', bg = 'none' })
    vim.api.nvim_set_hl(0, "StatusLineNC", { link = 'Normal' })

    if (first_param == nil) then
      vim.cmd(':DiffviewOpen')
    else
      vim.cmd(':DiffviewOpen ' .. first_param)
    end
  end
})
