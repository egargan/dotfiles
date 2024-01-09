return {
  {
    -- Convenience function library for plugin devs
    'nvim-lua/plenary.nvim',
  },

  {
    -- Neovim 'component library'
    'MunifTanjim/nui.nvim',
  },

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
        function() require('notify').dismiss() end,
        mode = { 'n' },
        desc = 'Dismiss notifications',
      }
    }
  },

  {
    'rmagatti/auto-session',
    lazy = false,
    opts = {
      auto_session_suppress_dirs = { "~/", "~/Downloads", "~/Desktop" },
      auto_save_enabled = true,
      auto_restore_enabled = true,
      auto_session_use_git_branch = true,
      pre_save_cmds = { 'NvimTreeClose', 'tabdo NvimTreeClose', 'SymbolsOutlineClose', 'tabdo SymbolsOutlineClose' },
      post_restore_cmds = {
        function()
          for bufnr = 1, vim.fn.bufnr('$') do
            if vim.fn.buflisted(bufnr) == 1 then
              vim.bo[bufnr].bufhidden = 'hide'
            end
          end
        end
      }
    }
  }
}
