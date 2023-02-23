-- UIs for viewing git diffs, history, etc.

return {
  name = 'toppair/reach.nvim',
  setup = function()
    require('reach').setup()

    vim.api.nvim_set_hl(0, 'ReachBorder', { link = '@comment' })
    vim.api.nvim_set_hl(0, 'ReachGrayOut', { link = '@comment' })
    vim.api.nvim_set_hl(0, 'ReachTitle', { link = '@comment' })
    vim.api.nvim_set_hl(0, 'ReachDirectory', { link = '@number' })
    vim.api.nvim_set_hl(0, 'ReachPriority', { link = '@label' })

    vim.api.nvim_set_hl(0, 'ReachHandleBuffer', { link = '@keyword' })
    vim.api.nvim_set_hl(0, 'ReachHandleSplit', { link = '@keyword' })
    vim.api.nvim_set_hl(0, 'ReachHandleMarkLocal', { link = '@keyword' })
    vim.api.nvim_set_hl(0, 'ReachHandleMarkGlobal', { link = '@keyword' })
    vim.api.nvim_set_hl(0, 'ReachHandleTabpage', { link = '@keyword' })
    vim.api.nvim_set_hl(0, 'ReachHandleDelete', { link = 'DiagnosticError' })

    vim.keymap.set('n', '<S-Tab>', function()
      require('reach').buffers({
        modified_icon = '+',
        filter = function(bufnr) return not (string.find(vim.api.nvim_buf_get_name(bufnr), 'NvimTree')) end,
        show_current = true,
        previous = {
          depth = 2,
          groups = {
            '@function',
            '@keyword',
          }

        }
      })
    end, { noremap = true, silent = true })
  end,
  priority = 1,
}
