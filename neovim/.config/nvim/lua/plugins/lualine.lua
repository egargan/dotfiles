-- Pretty status line

function setup()
  -- TODO: use darker colours?
  -- local custom_nord = require'lualine.themes.gruvbox'
  -- https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/themes/nord.lua

  require('lualine').setup({
      options = {
          icons_enabled = false,
          section_separators = '',
          component_separators = '',
      },
      sections = {
          lualine_a = { 'mode' },
          lualine_b = {
              {
                  'filename',
                  color = { fg = vim.g.terminal_color_7, bg = vim.g.terminal_color_0 },
              }
          },
          lualine_c = {
              {
                  'branch',
                  icons_enabled = true,
                  icon = '⌥',
                  color = { fg = vim.g.terminal_color_7, bg = vim.g.terminal_color_8 },
                  padding = { left = 1, right = 2 },
              },
              {
                  'diagnostics',
                  diagnostics_color = {
                      error = 'Error',
                      warn  = 'WarningMsg',
                      info  = { fg = vim.g.terminal_color_0, bg = vim.g.terminal_color_4 },
                      hint  = 'Hint',
                  },
                  sources = { 'nvim_diagnostic' },
              },
          },
          lualine_x = {
              'location',
              {
                  'progress',
                  padding = { left = 1, right = 2 },
              },
              {
                  'encoding',
                  fmt = function(encoding) return string.upper(encoding) end
              },
              {
                  'fileformat',
                  fmt = function(fileformat) return string.upper(fileformat) end
              },
              {
                  'filetype',
                  fmt = function(filetype) return filetype:sub(1, 1):upper() .. filetype:sub(2) end,
                  padding = { left = 1, right = 2 },
              },
          },
          lualine_y = {},
          lualine_z = {},
      }
  })
end

return {
    name = 'nvim-lualine/lualine.nvim',
    setup = setup,
}
