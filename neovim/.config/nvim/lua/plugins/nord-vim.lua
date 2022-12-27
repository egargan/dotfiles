-- Nord colorscheme

return {
  name = 'arcticicestudio/nord-vim',
  setup = function()
    -- Disable ugly all-background diff highlight groups
    vim.g.nord_uniform_diff_background = 1
    vim.cmd('colorscheme nord')
  end,
  priority = 1,
}
