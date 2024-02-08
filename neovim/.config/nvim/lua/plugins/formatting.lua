vim.g.formatting_enabled = true

vim.api.nvim_create_user_command('FormattingToggle', function()
  if not vim.g.formatting_enabled then
    vim.g.formatting_enabled = true
  else
    vim.g.formatting_enabled = false
  end
end, {
  desc = "Enables or disables on-save code formatting"
})

return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre" },
    cmd = { "ConformInfo" },
    opts = {
      format_on_save = function(bufnr)
        -- TODO: allow buffer-local flag, with vim.b.formatting_enabled?
        if not vim.g.formatting_enabled then
          return
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        ["markdown"] = { { "prettierd", "prettier" } },
        ["markdown.mdx"] = { { "prettierd", "prettier" } },
        javascript = { { "prettierd", "prettier" } },
        javascriptreact = { { "prettierd", "prettier" } },
        typescript = { { "prettierd", "prettier" } },
        typescriptreact = { { "prettierd", "prettier" } },
        graphql = { { "prettierd", "prettier" } },
        yaml = { { "prettierd", "prettier" } },
        python = { "black" },
        ["_"] = { "trim_whitespace" },
      },
    },
    keys = {
      {
        "<leader>f",
        mode = { "n", "v" },
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        desc = "Format buffer",
      },
    },
  },
}
