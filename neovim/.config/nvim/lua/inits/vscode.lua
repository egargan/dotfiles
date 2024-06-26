-- Sometimes Neovim doesn't think .nvim should be its runtime path?
vim.opt.rtp:append(vim.env.HOME .. '/.nvim/')

require("vscode.settings")
require("vscode.keymaps")

require('plugins.init')

require("lazy").setup({
  spec = {
    {
      -- Easy surrounding quotes, tags, parens, etc.
      'kylechui/nvim-surround',
      event = "VeryLazy",
      config = true,
    },

    {
      "folke/flash.nvim",
      event = "VeryLazy",
      ---@type Flash.Config
      opts = {
        highlight = {
          backdrop = false,
        },
        prompt = {
          prefix = { { "ϟ ", "FlashPromptIcon" } },
        }
      },
      -- stylua: ignore
      keys = {
        { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
        { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
        { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
        { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
        { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
      },
    },

    {
      -- Plugin dev-oriented tree sitter library
      'nvim-treesitter/nvim-treesitter',
      lazy = false,
      opts = {
        highlight = {
          enable = true,
          disable = { "scss" },
        },
        indent = {
          enable = true
        },
        ensure_installed = {
          "svelte",
          "typescript",
          "lua",
          "html",
          "scss",
          "python",
          "yaml",
          "json",
          "query",
          "javascript",
          "tsx",
          "jsonc",
          "bash",
          "regex",
        },
        incremental_selection = {
          enable = true,
        },
        keymaps = {
          init_selection = "gnn",
          node_incremental = "grn",
          scope_incremental = "grc",
          node_decremental = "grm",
        },
        matchup = {
          enable = true,
        },
      },
      config = function(_, opts)
        require('nvim-treesitter.configs').setup(opts)
        require('nvim-treesitter.install').update({ sync_install = false })()

        -- Leave error highlighting up to LSP
        vim.api.nvim_set_hl(0, '@error', { link = "Normal" })
      end
    },
    {
      'Wansmer/treesj',
      keys = {
        {
          "<leader>s",
          "<cmd>:TSJToggle<cr>",
          desc = "Split/join block"
        },
      },
      cmd = {
        'TSJToggle',
        'TSJSplit',
        'TSJJoin',
      },
      dependencies = { 'nvim-treesitter/nvim-treesitter' },
      opts = {
        use_default_keymaps = false,
      }
    },
  },
  change_detection = {
    enabled = false,
  },
})
