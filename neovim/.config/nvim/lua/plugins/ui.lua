local function TabsSpacesInfo()
  local tabstop = vim.opt.tabstop:get()
  return vim.opt.expandtab:get() and 'Spaces: ' .. tabstop or 'Tabs'
end

return {
  {
    -- Pretty notifications
    'rcarriga/nvim-notify',
    lazy = false,
    opts = {
      render = 'wrapped-compact',
      icons = {
        ERROR = "✘",
        WARN = "▲",
        INFO = "•",
        DEBUG = "•",
        TRACE = "•",
      },
      timeout = 3500,
    },
    config = function(_, opts)
      local notify = require("notify")

      vim.notify = notify

      -- Override default print function to use notify
      print = function(...)
        local print_safe_args = {}
        local _ = { ... }
        for i = 1, #_ do
          table.insert(print_safe_args, tostring(_[i]))
        end
        notify(table.concat(print_safe_args, ' '), "info")
      end

      require('notify').setup(opts)
    end,
    keys = {
      {
        '<Bs>',
        function()
          require('notify').dismiss()
          vim.cmd('noh')
        end,
        mode = { 'n' },
        desc = 'Dismiss notifications',
      }
    }
  },

  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
    opts = {
      cmdline = {
        format = {
          cmdline = { icon = ">" },
          search_down = { icon = " /" },
          search_up = { icon = " /" },
          filter = { icon = "$" },
          lua = { icon = "l" },
          help = { icon = "?" },
        },
      },
      format = {
        level = {
          icons = {
            error = "✘",
            warn = "▲",
            info = "•",
          },
        },
      },
      popupmenu = {
        kind_icons = false,
      },
      lsp = {
        progress = {
          enabled = false,
        },
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,         -- use a classic bottom cmdline for search
        long_message_to_split = true, -- long messages will besent to a split
        lsp_doc_border = true,        -- add a border to hover docs and signature help
      },
      routes = {
        {
          -- Filter basic 'noise' messages like 'file written', 'search hit TOP', etc
          filter = {
            event = "msg_show",
            kind = { "", "wmsg" }
          },
          opts = { skip = true },
        },
      },
    },
  },

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
        a = { bg = vim.g.nord_colors.polar_night.origin },
        b = { bg = vim.g.nord_colors.polar_night.origin },
        c = { bg = vim.g.nord_colors.polar_night.origin },
      }

      require('lualine').setup({
        options = {
          theme = nord_theme,
          icons_enabled = true,
          section_separators = '',
          component_separators = '',
          always_divide_middle = true,
          disabled_filetypes = {
            winbar = { 'NvimTree' },
          },
          refresh = {
            statusline = 500
          }
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = {
            {
              'branch',
              icons_enabled = true,
              icon = '⌥',
              color = {
                bg = vim.g.nord_colors.polar_night.brightest,
              },
            },
          },
          lualine_c = {},
          lualine_x = {
            {
              function()
                return require("noice").api.statusline.mode.get():sub(11, -1)
              end,
              cond = function()
                return require("noice").api.statusline.mode.has() and
                    require("noice").api.statusline.mode.get():sub(1, 9) == "recording"
              end,
              icon = { '•', color = { fg = "#D08770" } },
            },
            {
              'diagnostics',
              diagnostics_color = {
                error = { fg = vim.g.nord_colors.snow_storm.origin, bg = vim.g.nord_colors.aurora.red },
                warn  = { fg = vim.g.nord_colors.snow_storm.origin, bg = vim.g.nord_colors.aurora.yellow },
                info  = { fg = vim.g.nord_colors.snow_storm.origin, bg = vim.g.nord_colors.frost.artic_water },
                hint  = { fg = vim.g.nord_colors.snow_storm.origin, bg = vim.g.nord_colors.frost.artic_ocean },
              },
              sources = { 'nvim_diagnostic' },
              icons_enabled = false,
            },
            {
              function()
                local buf_clients = vim.lsp.buf_get_clients()

                if #buf_clients == 0 then
                  return ""
                elseif #buf_clients == 1 then
                  return "1 LSP"
                else
                  return #buf_clients .. " LSPs"
                end
              end,
              icon = {
                '•',
                color = { fg = vim.g.nord_colors.aurora.green }
              },
            },
            {
              function()
                if (vim.g.formatting_enabled) then
                  return "✔"
                else
                  return "✘"
                end
              end,
              color = function()
                local fg_color = nil
                if (vim.g.formatting_enabled) then
                  fg_color = vim.g.nord_colors.aurora.green
                else
                  fg_color = vim.g.nord_colors.aurora.red
                end
                return { fg = fg_color }
              end
            },
            {
              function()
                return "Fmt"
              end,
              padding = 0,
            },
            'location',
            -- {
            --   'progress',
            --   padding = { left = 1, right = 2 },
            -- },
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
                if (string.find(name, 'OUTLINE')) then
                  return 'Symbols'
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
              color = {
                bg = vim.g.nord_colors.polar_night.origin,
              },
            }
          },
          lualine_x = {
          },
          lualine_y = {
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
                if (string.find(name, 'OUTLINE')) then
                  return 'Symbols'
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
}
