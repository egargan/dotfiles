-- Automatic session restore and create

return {
  name = 'olimorris/persisted.nvim',
  setup = function()
    require("persisted").setup({
      use_git_branch = true,
      autoload = true,
    })
  end
}
