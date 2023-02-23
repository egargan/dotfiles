-- TODO:
-- get Lspsaga's show_outline working, or alternative plugin
-- use Lspsaga's winbar support?

function setup()
  local opts = { noremap = true, silent = true }

  -- on_attach means these settings will only be applied once the server attaches to the buffer
  local on_attach = function(client, bufnr)
    local bufopts = { noremap = true, silent = true, buffer = bufnr }

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<Leader>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<Leader>r', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<Leader>ca', function() vim.cmd(':CodeActionMenu') end, bufopts)
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

    vim.keymap.set('n', '[e', function()
      vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
    end, opts)
    vim.keymap.set('n', ']e', function()
      vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
    end, opts)

    vim.diagnostic.config({
      float = {
        border = 'rounded',
        header = 'Diagnostics',
        source = true,
      },
    })

    if client.server_capabilities.documentFormattingProvider then
      vim.api.nvim_create_autocmd('BufWritePost', {
        buffer = bufnr,
        callback = function() vim.lsp.buf.format({ sync = true }) end
      })
    end

    if client.server_capabilities.documentHighlightProvider then
      vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
      vim.api.nvim_clear_autocmds { buffer = bufnr, group = "lsp_document_highlight" }
      vim.api.nvim_create_autocmd("CursorHold", {
        callback = vim.lsp.buf.document_highlight,
        buffer = bufnr,
        group = "lsp_document_highlight",
        desc = "Document Highlight",
      })
      vim.api.nvim_create_autocmd("CursorMoved", {
        callback = vim.lsp.buf.clear_references,
        buffer = bufnr,
        group = "lsp_document_highlight",
        desc = "Clear All the References",
      })
    end
  end

  -- Show black circle instead of default square for virtual text diagnostic messages
  vim.diagnostic.config({
    virtual_text = {
      prefix = ' ●',
    },
    signs = false,
  })

  -- Create commands for hiding/showing diagnostic virtual text
  vim.api.nvim_create_user_command('HideDiagnosticVirtualText', function()
    vim.diagnostic.config({ virtual_text = false })
  end, { nargs = 0 })
  vim.api.nvim_create_user_command('ShowDiagnosticVirtualText', function()
    vim.diagnostic.config({ virtual_text = true })
  end, { nargs = 0 })

  -- Add borders to signature help and hover popups
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help, { border = 'rounded' }
  )
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, { border = 'rounded' }
  )

  -- Config lspconfig UIs
  require('lspconfig.ui.windows').default_options.border = 'rounded'
  vim.api.nvim_set_hl(0, 'LspInfoBorder', { link = 'Comment' })

  -- TODO: find a way of forcing the workspace to '.config/nvim', the current hack is to put an
  -- empty 'stylua.toml' file next to this, without it sumneok_lua assumes ~ is the working
  -- directory, which the language server will refuse to load
  --
  -- if vim.fn.getreg('%') == '.config/nvim/init.lua' then
  -- ...
  -- end

  -- Setup Mason LSP installer UI
  require('mason').setup({
    ui = {
      border = 'rounded',
    }
  })

  local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

  -- TODO: can we do this more elegantly?
  for _, value in pairs(vim.fn.systemlist('ls $HOME/.config/nvim/lua/lsp/langs | sed -e \'s/\\.lua$//\'')) do
    require('lsp.langs.' .. value)(capabilities, on_attach)
  end

  -- Setup auto-signature help plugin
  require('lsp_signature').setup({
    hint_enable = false,
    toggle_key = '<C-h>',
  })

  -- Setup diagnostic summary plugin
  require('trouble').setup({
    icons = false,
    fold_open = '▾',
    fold_closed = '▸',
    signs = {
      error = '●',
      warning = '●',
      hint = '●',
      information = '●',
    },
    use_diagnostic_signs = false
  })

  vim.keymap.set('n', '<Leader>t', require('trouble').toggle, { noremap = true, silent = true })
  vim.keymap.set('n', '<Leader>fr', ':Trouble lsp_references<cr>', { noremap = true, silent = true })
  vim.keymap.set('n', '<Leader>fi', ':Trouble lsp_implementations<cr>', { noremap = true, silent = true })
  vim.keymap.set('n', '<Leader>fd', ':Trouble document_diagnostics<cr>', { noremap = true, silent = true })
  vim.keymap.set('n', '<Leader>fD', ':Trouble workspace_diagnostics<cr>', { noremap = true, silent = true })

  -- null-ls interfaces tools with Neovim's LSP that aren't supported by nvim-lspconfig
  local null_ls = require('null-ls')

  null_ls.setup({
    sources = {
      null_ls.builtins.formatting.prettierd,
    },
  })

  -- Configure code action plugin
  vim.g.code_action_menu_show_details = false
  vim.g.code_action_menu_show_action_kind = false

  -- Setup code action lightbulb plugin
  require('nvim-lightbulb').setup({
    sign = { enabled = false },
    virtual_text = { enabled = true },
    autocmd = { enabled = true },
  })
end

return {
  plugins = {
    -- Per-langauge client configs
    'neovim/nvim-lspconfig',

    -- LSP server installer
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',

    -- Show signature help while typing
    'ray-x/lsp_signature.nvim',

    -- Diagnostic summary plugin
    'folke/trouble.nvim',

    -- Fancy code action menu
    'weilbith/nvim-code-action-menu',

    -- Show lightbulg when code actions available
    'kosayoda/nvim-lightbulb',

    -- Platform for easier LSP features, e.g. formatting and linting
    'jose-elias-alvarez/null-ls.nvim'
  },
  setup = setup,
}
