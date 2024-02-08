return {
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
