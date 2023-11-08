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
      local nord_theme = require('lualine.themes.nord')

      nord_theme.inactive = {
        a = {
          fg = vim.g.nord_colors.polar_night.brightest,
          gui = 'underline,bold',
        },
        b = {
          fg = vim.g.nord_colors.polar_night.brightest,
          gui = 'underline,bold',
        },
        c = {
          fg = vim.g.nord_colors.polar_night.brightest,
          gui = 'underline,bold',
        },
      }

      require('lualine').setup({
        options = {
          theme = nord_theme,
          icons_enabled = false,
          section_separators = '',
          component_separators = '',
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = {
            {
              'branch',
              icons_enabled = true,
              icon = '⌥',
              color = { fg = vim.g.terminal_color_7, bg = vim.g.terminal_color_8 },
              padding = { left = 1, right = 2 },
            },
          },
          lualine_c = {},
          lualine_x = {
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
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {},
        },
        winbar = {
          lualine_a = {
            {
              'filename',
              path = 4,
              file_status = false,
              color = function()
                return {
                  fg = vim.g.nord_colors.snow_storm.origin,
                  bg = vim.g.nord_colors.polar_night.origin,
                  gui = (vim.bo.bufhidden == 'wipe' or vim.bo.bufhidden == 'delete') and 'italic,bold' or 'bold'
                }
              end,
              fmt = function(name)
                if (string.find(name, 'NvimTree_')) then
                  return 'File Tree'
                end
                return name
              end
            }
          },
          lualine_b = {
            {
              function()
                if (vim.api.nvim_buf_get_option(0, 'modified')) then
                  return '•'
                elseif (vim.api.nvim_buf_get_option(0, 'readonly')) then
                  return '∅'
                else
                  return ''
                end
              end,
              padding = { left = 0, right = 1 },
              color = function()
                local fg_color = vim.g.nord_colors.polar_night.origin
                if (vim.api.nvim_buf_get_option(0, 'modified')) then
                  fg_color = vim.g.nord_colors.frost.ice
                elseif (vim.api.nvim_buf_get_option(0, 'readonly')) then
                  fg_color = vim.g.nord_colors.aurora.orange
                end
                return {
                  fg = fg_color,
                  bg = vim.g.nord_colors.polar_night.origin,
                }
              end
            }
          },
          lualine_c = {
            {
              function()
                local navic = require('nvim-navic')
                if (navic.is_available()) then
                  local location = navic.get_location({})
                  if (location and location ~= nil and location ~= "") then
                    return location
                  end
                end
                return " "
              end,
              color = { bg = vim.g.nord_colors.polar_night.origin }
            }
          },
        },
        inactive_winbar = {
          lualine_a = {
            {
              'filename',
              path = 4,
              file_status = false,
              color = function()
                return {
                  fg = vim.g.nord_colors.polar_night.light,
                  bg = vim.g.nord_colors.polar_night.origin,
                  gui = (vim.bo.bufhidden == 'wipe' or vim.bo.bufhidden == 'delete') and 'italic,bold' or 'bold'
                }
              end,
              fmt = function(name)
                if (string.find(name, 'NvimTree_')) then
                  return 'File Tree'
                end
                return name
              end
            }
          },
          lualine_b = {
            {
              function()
                if (vim.api.nvim_buf_get_option(0, 'modified')) then
                  return '•'
                elseif (vim.api.nvim_buf_get_option(0, 'readonly')) then
                  return '∅'
                else
                  return ''
                end
              end,
              padding = { left = 0, right = 1 },
              color = function()
                local fg_color = vim.g.nord_colors.polar_night.origin
                if (vim.api.nvim_buf_get_option(0, 'modified')) then
                  fg_color = vim.g.nord_colors.frost.ice
                elseif (vim.api.nvim_buf_get_option(0, 'readonly')) then
                  fg_color = vim.g.nord_colors.aurora.orange
                end
                return {
                  fg = fg_color,
                  bg = vim.g.nord_colors.polar_night.origin,
                }
              end
            }
          },
          lualine_c = {},
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
      {
        "!",
        mode = { 'n' },
        function() vim.cmd(':ToggleTerm direction=float') end,
        desc = "Toggle floating terminal"
      },
      {
        "<leader>g",
        mode = { 'n' },
        function()
          require('toggleterm.terminal').Terminal:new({
            cmd = "lazygit",
            direction = "float",
            float_opts = {
              width = 120,
              height = 40,
            }
          }):toggle()
        end,
        desc = "Toggle floating lazygit terminal"
      },
    }
  }
}
