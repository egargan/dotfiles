-- Plugin dev-oriented tree sitter library

return {
    name = 'windwp/nvim-ts-autotag',
    setup = function()
      require('nvim-ts-autotag').setup()
    end
}
