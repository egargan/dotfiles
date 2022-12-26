-- TODO:
-- get Lspsaga's show_outline working, or alternative plugin
-- use Lspsaga's winbar support?

function setup()
  local opts = { noremap = true, silent = true }

  -- on_attach means these settings will only be applied once the server attaches to the buffer
  local on_attach = function(client, bufnr)
    local bufopts = { noremap = true, silent = true, buffer = bufnr }

    -- Add diagnostics to quickfix list
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

    -- Setup fancy LSP features
    require('lspsaga').init_lsp_saga({
      code_action_lightbulb = {
        sign = false,
      },
      finder_icons = {
        def = '> ',
        ref = '> ',
        imp = '> ',
        link = '> ',
      },
      diagnostic_header = { '> ', '> ', '> ', '> ' },
      max_preview_lines = 15,
    })

    vim.api.nvim_set_hl(0, 'LspSagaLightBulb', { link = 'Todo' })

    vim.api.nvim_set_hl(0, 'FinderParam', { link = 'Function' })
    vim.api.nvim_set_hl(0, 'FinderVirtText' , { link = 'DiagnosticError' })
    vim.api.nvim_set_hl(0, 'LspSagaAutoPreview', { link = 'Comment' })
    vim.api.nvim_set_hl(0, 'LspSagaFinderSelection' , { link = 'Bold' })
    vim.api.nvim_set_hl(0, 'LspSagaLspFinderBorder', { link = 'Comment' })
    vim.api.nvim_set_hl(0, 'FinderSpinner', { link = 'Function' })
    vim.api.nvim_set_hl(0, 'FinderSpinnerBorder', { link = 'Comment' })
    vim.api.nvim_set_hl(0, 'FinderSpinnerTitle', { link = 'Function' })
    vim.api.nvim_set_hl(0, 'Definitions' , { link = 'Number' })
    vim.api.nvim_set_hl(0, 'DefinitionsIcon' , { link = 'Todo' })
    vim.api.nvim_set_hl(0, 'Implements' , { link = 'Number' })
    vim.api.nvim_set_hl(0, 'ImplementsIcon' , { link = 'Todo' })
    vim.api.nvim_set_hl(0, 'References' , { link = 'Number' })
    vim.api.nvim_set_hl(0, 'ReferencesIcon' , { link = 'Todo' })

    vim.api.nvim_set_hl(0, 'LspSagaHoverBorder' , { link = 'Comment' })

    vim.api.nvim_set_hl(0, 'LspSagaDiagnosticBorder' , { link = 'Comment' })
    vim.api.nvim_set_hl(0, 'LspSagaDiagnosticHeader' , { link = 'Normal' })

    vim.api.nvim_set_hl(0, 'LspSagaCodeActionTitle' , { link = 'Normal' })
    vim.api.nvim_set_hl(0, 'LspSagaCodeActionBorder' , { link = 'Comment' })
    vim.api.nvim_set_hl(0, 'LspSagaCodeActionTrunCateLine' , { link = 'Comment' })
    vim.api.nvim_set_hl(0, 'LspSagaCodeActionContent' , { link = 'Todo' })

    vim.api.nvim_set_hl(0, 'DefinitionArrow' , { link = 'Comment' })
    vim.api.nvim_set_hl(0, 'DefinitionFile' , { link = 'Function' })

    vim.keymap.set({ 'n', 'v' }, '<leader>ca', '<cmd>Lspsaga code_action<CR>', bufopts)

    -- Lsp finder find the symbol definition implement reference
    -- if there is no implement it will hide
    -- when you use action in finder like open vsplit then you can
    -- use <C-t> to jump back
    vim.keymap.set("n", "gh", "<cmd>Lspsaga lsp_finder<CR>", bufopts)

    -- Rename
    vim.keymap.set("n", "gr", "<cmd>Lspsaga rename<CR>", bufopts)

    -- Peek and goto definition
    vim.keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", bufopts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.definition, bufopts)

    -- Show line diagnostics
    vim.keymap.set("n", "<leader>ld", "<cmd>Lspsaga show_line_diagnostics<CR>", bufopts)

    -- Navigate diagnostics
    vim.keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", bufopts)
    vim.keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", bufopts)

    -- Navigate error diagnostics
    vim.keymap.set("n", "[e", function()
      require("lspsaga.diagnostic").goto_prev({ severity = vim.diagnostic.severity.ERROR })
    end, bufopts)
    vim.keymap.set("n", "]e", function()
      require("lspsaga.diagnostic").goto_next({ severity = vim.diagnostic.severity.ERROR })
    end, bufopts)

    -- Hover Doc
    vim.keymap.set("n", "<C-k>", "<cmd>Lspsaga hover_doc<CR>", bufopts)
  end

  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      -- Disable diagnostic signs, they look ugly next to git signs
      signs = false,
    }
  )

  -- Show black circle instead of default square for virtual text diagnostic messages
  vim.diagnostic.config({
    virtual_text = {
      prefix = ' ●' ,
    }
  })

  -- TODO: find a way of forcing the workspace to '.config/nvim', the current hack is to put an
  -- empty 'stylua.toml' file next to this, without it sumneok_lua assumes ~ is the working
  -- directory, which the language server will refuse to load
  --
  -- if vim.fn.getreg('%') == '.config/nvim/init.lua' then
  -- ...
  -- end

  -- Setup Mason LSP installer UI
  require('mason').setup()

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
end

return {
  plugins = {
    -- Per-langauge client configs
    'neovim/nvim-lspconfig',

    -- LSP server installer
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',

    -- Fancy LSP features
    'glepnir/lspsaga.nvim',

    -- Show signature help while typing
    'ray-x/lsp_signature.nvim',
  },
  setup = setup,
}
