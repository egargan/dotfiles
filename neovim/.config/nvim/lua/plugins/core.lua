return {
  {
    -- Convenience function library for plugin devs
    'nvim-lua/plenary.nvim',
  },

  {
    -- Package manager
    "folke/lazy.nvim",
    lazy = false,
    version = "*",
  },

  {
    -- Neovim 'component library'
    'MunifTanjim/nui.nvim',
  },

  {
    -- Pretty notifications
    'rcarriga/nvim-notify',
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
    }
  },

  {
    'rmagatti/auto-session',
    lazy = false,
    opts = {
      auto_session_suppress_dirs = { "~/", "~/Downloads", "~/Desktop" },
      auto_save_enableda = true,
      auto_restore_enabled = true,
      auto_session_use_git_branch = true,
      pre_save_cmds = { 'NvimTreeClose', 'tabdo NvimTreeClose', 'SymbolsOutlineClose', 'tabdo SymbolsOutlineClose' },
    }
  }
}
