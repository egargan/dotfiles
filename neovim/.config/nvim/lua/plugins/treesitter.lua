return {
  {
    -- Helper tool for debugging treesitter
    'nvim-treesitter/playground',
    cmd = 'TSPlaygroundToggle',
    dependencies = { "nvim-treesitter" },
  },

  {
    -- Plugin dev-oriented tree sitter library
    'nvim-treesitter/nvim-treesitter',
    event = { "BufReadPre", "BufNewFile" },
    lazy = false,
    opts = {
      highlight = {
        enable = true,
        disable = { "scss" },
      },
      indent = {
        enable = true
      },
      autotag = {
        enable = true,
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
        "tsx"
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
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
      require('nvim-treesitter.install').update({ sync_install = false })()

      -- Leave error highlighting up to LSP
      vim.api.nvim_set_hl(0, '@error', { link = "Normal" })
    end
  },
}
