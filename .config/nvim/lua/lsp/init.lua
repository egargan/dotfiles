function setup()
  local opts = { noremap = true, silent = true }

  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

  -- on_attach means these settings will only be applied once the server attaches to the buffer
  local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- TODO: work through these
    local bufopts = { noremap = true, silent = true, buffer = bufnr }

    -- References handled by Telescope conf
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<Leader>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<Leader>r', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<Leader>ca', vim.lsp.buf.code_action, bufopts)
  end

  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      -- Disable diagnostic signs, they look ugly next to git signs
      signs = false,
    }
  )

  -- Show black circle instead of default square for virtual text diagnostic messages
  vim.diagnostic.config({ virtual_text = { prefix = ' ●' } })

  -- TODO: find a way of forcing the workspace to '.config/nvim', the current hack is to put an
  -- empty 'stylua.toml' file next to this, without it sumneok_lua assumes ~ is the working
  -- directory, which the language server will refuse to load
  --
  -- if vim.fn.getreg('%') == '.config/nvim/init.lua' then
  -- ...
  -- end

  -- Setup Mason LSP installer UI
  require('mason').setup()

  local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

  -- TODO: can we do this more elegantly?
  for _, value in pairs(vim.fn.systemlist('ls $HOME/.config/nvim/lua/lsp/langs | sed -e \'s/\\.lua$//\'')) do
    require('lsp.langs.' .. value)(capabilities, on_attach)
  end
end

return {
  plugins = {
    -- Per-langauge client configs
    'neovim/nvim-lspconfig',

    -- LSP server installer
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
  },
  setup = setup,
}
