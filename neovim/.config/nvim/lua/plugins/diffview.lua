-- UIs for viewing git diffs, history, etc.

return {
    name = 'sindrets/diffview.nvim',
    setup = function()
      require("diffview").setup({
          use_icons = false,
          icons = {
              folder_closed = "> ",
              folder_open = "v ",
          },
          signs = {
              fold_closed = ">",
              fold_open = "v",
              done = "✓",
          },
      })

      local keymap_opts = { noremap = true, silent = true }

      vim.keymap.set('n', '<Leader>+', function() vim.cmd(':DiffviewOpen') end, keymap_opts)
      vim.keymap.set('n', '<Leader>%', function() vim.cmd(':DiffviewFileHistory %') end, keymap_opts)
    end
}
