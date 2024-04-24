return {
  {
    -- Commands for opening files, lines in GitHub
    'Almo7aya/openingh.nvim',
    cmd = { 'OpenInGHFile', 'OpenInGHRepo' }
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = {
      "MarkdownPreviewToggle",
      "MarkdownPreview",
      "MarkdownPreviewStop"
    },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },

  {
    'cshuaimin/ssr.nvim',
    keys = {
      {
        '<leader>R',
        function() require("ssr").open() end,
        mode = { 'n', 'x', 'v' },
        desc = "Structured search and replace"
      }
    },
    opts = {
      border = "rounded",
      min_width = 50,
      min_height = 5,
      max_width = 120,
      max_height = 25,
      adjust_window = true,
      keymaps = {
        close = "q",
        next_match = "n",
        prev_match = "N",
        replace_confirm = "<cr>",
        replace_all = "<leader><cr>",
      }
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
      { "<leader>=", function() vim.cmd(':DiffviewFileHistory') end,   desc = "Show git history for current file" },
      { "<leader>%", function() vim.cmd(':DiffviewFileHistory %') end, desc = "Show git history" },
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
              width = 150,
              height = 50,
            },
            on_open = function(term)
              vim.cmd("startinsert!")
              -- Remove global '<Esc> to C-\C-n' map, so that we can actually
              -- use escape in laygit
              vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<Esc>", { noremap = true, silent = true })
            end,
          }):toggle()
        end,
        desc = "Toggle floating lazygit terminal"
      },
    }
  },

  {
    -- Speedy buffer navigation
    'ggandor/leap.nvim',
    event = "VeryLazy",
    config = function()
      -- Only use normal mappings (see :h leap-default-mappings)
      vim.keymap.set('n', 's', '<Plug>(leap-forward)')
      vim.keymap.set('n', 'S', '<Plug>(leap-backward)')
    end
  },

  {
    'zbirenbaum/copilot.lua',
    cmd = "Copilot",
    event = "VeryLazy",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 100,
          keymap = {
            accept = "<C-l>",
            accept_word = false,
            accept_line = false,
            next = "<C-k>",
            prev = "<C-j>",
            dismiss = "<C-h>",
          },
        },
      })
    end,
  },

  {
    -- Visualise hex colors, RGB values, etc in buffer
    'NvChad/nvim-colorizer.lua',
    event = "VeryLazy",
    opts = {
      user_default_options = {
        -- Don't highlight CSS names, e.g. 'white', 'coral', etc
        names = false
      }
    }
  },

  {
    'FabijanZulj/blame.nvim',
    config = true,
    keys = {
      {
        '<Leader>B',
        mode = { 'n' },
        function() vim.cmd(':BlameToggle') end,
        desc = "Toggle Git blame buffer"
      }
    }
  },
}
