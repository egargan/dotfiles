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
    -- Automatic session restore and create
    'olimorris/persisted.nvim',
    lazy = false,
    opts = {
      use_git_branch = true,
      autoload = true,
    },
  }
}
