-- Modal fuzzy finder for everything under the sun

function setup()
  local telescope_builtins = require('telescope.builtin')
  local telescope_themes = require('telescope.themes')

  local opts = { noremap = true, silent = true }

  vim.keymap.set('n', '\\', telescope_builtins.live_grep, opts)

  -- live_grep search with visual selection filled
  vim.keymap.set('v', '\\', '"zy:Telescope live_grep default_text=<C-r>z<cr>', opts)

  -- TODO: add no-ignore versions of above, don't think the live_grep builtin supports this out the box
  -- TODO: add bindings for LSP

  vim.keymap.set('n', '<C-t>', function() telescope_builtins.find_files(telescope_themes.get_dropdown()) end, opts)

  vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "Comment" })

  vim.api.nvim_set_hl(0, "TelescopeResultsLineNr", { link = "Comment" })
  vim.api.nvim_set_hl(0, "TelescopeResultsIdentifier", { link = "Comment" })
  vim.api.nvim_set_hl(0, "TelescopeResultsNumber", { link = "Comment" })
  vim.api.nvim_set_hl(0, "TelescopeMatching", { link = "Annotation" })

  require('telescope').setup({
    defaults = {
      vimgrep_arguments = {
        "rg",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case"
      }
    }
  })

  -- TODO: make this nicer, do it in the actual plugin setup?
  require("telescope").load_extension("file_browser")
end

return {
  name = 'nvim-telescope/telescope.nvim',
  setup = setup,
}
