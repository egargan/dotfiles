-- Buffer pinning and navigation plugin

function setup()
  require("harpoon").setup({
    menu = {
      width = 60,
      height = 6,
    }
  })

  vim.keymap.set('n', '<C-h>', require('harpoon.mark').add_file, opts)
  vim.keymap.set('n', '<S-Tab>', require("harpoon.ui").toggle_quick_menu, opts)

  vim.keymap.set('n', '1', function() require("harpoon.ui").nav_file(1) end, opts)
  vim.keymap.set('n', '2', function() require("harpoon.ui").nav_file(2) end, opts)
  vim.keymap.set('n', '3', function() require("harpoon.ui").nav_file(3) end, opts)
  vim.keymap.set('n', '4', function() require("harpoon.ui").nav_file(4) end, opts)
  vim.keymap.set('n', '5', function() require("harpoon.ui").nav_file(5) end, opts)
  vim.keymap.set('n', '6', function() require("harpoon.ui").nav_file(6) end, opts)

  vim.api.nvim_set_hl(0, "HarpoonBorder", { link = "Comment" })

  -- TODO: display harpoon marks in status line?
  -- require('harpoon.mark').get_marked_file_name(idx)

  -- TODO: hide numbers in tabline, avoid confusion between it + harpoon
end

return {
  name = 'ThePrimeagen/harpoon',
  setup = setup,
}
