function setup()
  -- Set up nvim-cmp
  local cmp = require('cmp')

  cmp.setup({
    window = {
      completion = cmp.config.window.bordered({
        winhighlight = "Normal:Normal,FloatBorder:Comment,CursorLine:PmenuSel,Search:None",
      }),
      documentation = cmp.config.window.bordered({
        winhighlight = "Normal:Normal,FloatBorder:Comment,CursorLine:PmenuSel,Search:None",
      })
    },
    mapping = cmp.mapping.preset.insert({
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      -- Scroll complete docs menu
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      -- Select next or previous suggestion
      ['<Tab>'] = cmp.mapping.select_next_item(),
      ['<S-Tab>'] = cmp.mapping.select_prev_item(),
      -- Manually trigger completion menu
      ['<C-Space>'] = cmp.mapping.complete(),
      -- Close completion menu
      ['<C-c>'] = cmp.mapping.abort(),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
    }),
    snippet = {
      -- Register snippets engine
      expand = function(args) vim.fn["vsnip#anonymous"](args.body) end,
    }
  })

  -- Use cmdline source for ':'
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'cmdline' }
    })
  })
end

return {
  plugins = {
    -- Auto-complete Framework
    'hrsh7th/nvim-cmp',

    -- Collects language server suggestions as completion source
    'hrsh7th/cmp-nvim-lsp',

    -- Completion source for vim's command line
    'hrsh7th/cmp-cmdline',

    -- Snippet engine, needed to make LSP snippet completions work
    -- TODO: move this into standalone 'snippets' dir?
    'hrsh7th/vim-vsnip',
    'hrsh7th/vim-vsnip-integ'
  },
  setup = setup,
}
