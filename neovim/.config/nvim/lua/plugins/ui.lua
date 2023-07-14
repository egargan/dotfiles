local function TabsSpacesInfo()
  local tabstop = vim.opt.tabstop:get()
  return vim.opt.expandtab:get() and 'Spaces: ' .. tabstop or 'Tabs'
end

return {
  {
    -- Pretty status line
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'nord.nvim',
      'SmiteshP/nvim-navic',
    },
    lazy = false,
    config = function()
      require('lualine').setup({
        options = {
          theme = 'nord',
          icons_enabled = false,
          section_separators = '',
          component_separators = '',
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = {
            {
              'filename',
              path = 4,
              color = function()
                return {
                  fg = vim.g.nord_colors.snow_storm.origin,
                  gui = (vim.bo.bufhidden == 'wipe' or vim.bo.bufhidden == 'delete') and 'italic',
                }
              end,
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
            { TabsSpacesInfo },
            {
              'filetype',
              fmt = function(filetype) return filetype:sub(1, 1):upper() .. filetype:sub(2) end,
              padding = { left = 1, right = 2 },
            },
          },
          lualine_y = {},
          lualine_z = {},
        },
        winbar = {
          lualine_a = {
            {
              function()
                local navic = require('nvim-navic')

                if (navic.is_available()) then
                  return navic.get_location({})
                else
                  return ""
                end
              end,
            }
          },
        },
      })
    end
  },

  {
    -- Filesystem explorer
    'nvim-tree/nvim-tree.lua',
    cmd = { 'NvimTree', 'NvimTreeToggle' },
    opts = {
      view = {
        width = 35,
      },
      filters = {
        git_clean = false,
      },
      renderer = {
        full_name = true,
        special_files = {},
        add_trailing = true,
        group_empty = true,
        highlight_git = true,
        indent_markers = {
          enable = true,
          inline_arrows = true,
          icons = {
            corner = "│",
          },
        },
        icons = {
          symlink_arrow = " → ",
          git_placement = "signcolumn",
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
      actions = {
        file_popup = {
          open_win_config = {
            border = 'rounded',
          },
        }
      },
    },
    keys = {
      { "<leader>e", function() vim.cmd('NvimTreeToggle') end,   desc = "Open NvimTree" },
      { "<leader>5", function() vim.cmd('NvimTreeFindFile') end, desc = "Open NvimTree at %" },
    }
  },

  {
    -- UIs for viewing git diffs, history, etc.
    'sindrets/diffview.nvim',
    cmd = {
      'DiffviewToggleFiles',
      'DiffviewOpen',
      'DiffviewFileHistory',
      'DiffviewLog',
      'DiffviewClose',
      'DiffviewRefresh',
      'DiffviewFocusFiles',
    },
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
    keys = {
      { "<leader>+", function() vim.cmd(':DiffviewOpen') end,          desc = "Show diffs UI" },
      { "<leader>%", function() vim.cmd(':DiffviewFileHistory %') end, desc = "Show file history" },
    }
  },

  {
    -- Toggle-able terminal
    'akinsho/toggleterm.nvim',
    cmd = {
      'ToggleTerm',
    },
    config = {
      highlights = {
        FloatBorder = {
          link = "Comment",
        },
      },
      float_opts = {
        border = 'rounded',
        width = 100,
        height = 30,
      }
    },
    keys = {
      { "!", mode = { 'n' }, function() vim.cmd(':ToggleTerm direction=float') end, desc = "Toggle floating terminal" },
    }
  }
}
