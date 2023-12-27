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
    -- Automatic session restore and create
    'olimorris/persisted.nvim',
    lazy = false,
    opts = {
      use_git_branch = true,
      autoload = true,
    },
  }
}
