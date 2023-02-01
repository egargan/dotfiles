---@diagnostic disable: redundant-parameter
-- Show git diff UI in gutter

function setup()
  require('gitsigns').setup {
    current_line_blame_opts = {
      delay = 500,
    },
    preview_config = {
      row = 1,
    },
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      -- Navigation
      vim.keymap.set('n', ']c', function()
        if vim.wo.diff then return ']c' end
        vim.schedule(function() gs.next_hunk() end)
        return '<Ignore>'
      end, { expr = true, buffer = bufnr })

      vim.keymap.set('n', '[c', function()
        if vim.wo.diff then return '[c' end
        vim.schedule(function() gs.prev_hunk() end)
        return '<Ignore>'
      end, { expr = true, buffer = bufnr })

      -- Actions
      vim.keymap.set({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>', { buffer = bufnr })
      vim.keymap.set({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>', { buffer = bufnr })
      vim.keymap.set('n', '<leader>hS', gs.stage_buffer, { buffer = bufnr })
      vim.keymap.set('n', '<leader>hu', gs.undo_stage_hunk, { buffer = bufnr })
      vim.keymap.set('n', '<leader>hR', gs.reset_buffer, { buffer = bufnr })
      vim.keymap.set('n', '<leader>hp', gs.preview_hunk, { buffer = bufnr })
      vim.keymap.set('n', '<leader>hb', function() gs.blame_line{full=true} end, { buffer = bufnr })
      vim.keymap.set('n', '<leader>hd', gs.diffthis, { buffer = bufnr })

      -- Text object
      vim.keymap.set({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { buffer = bufnr })
   end
  }
end

return {
  name = 'lewis6991/gitsigns.nvim',
  setup = setup,
}
