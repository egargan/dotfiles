-- Buffer pinning and navigation plugin

function setup()
  require("harpoon").setup({
    menu = {
      width = 60,
      height = 20,
    }
  })

  vim.keymap.set('n', '<C-h>', require('harpoon.mark').add_file, opts)
  vim.keymap.set('n', '<S-Tab>', require("harpoon.ui").toggle_quick_menu, opts)

  vim.api.nvim_set_hl(0, "HarpoonBorder", { link = "Comment" })

  vim.api.nvim_create_autocmd('BufReadPre', {
    pattern = '*',
    callback = function(event) require('harpoon.mark').add_file(event.file) end
  })
end

return {
  name = 'ThePrimeagen/harpoon',
  setup = setup,
  disabled = true,
}
