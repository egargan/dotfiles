local keymap_opts = { noremap = true, silent = true }

-- TODO: break me down, a la
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/lsp/init.lua#L72
local function on_attach(client, bufnr)
  local bufopts = { noremap = true, buffer = bufnr }

  if client.name == 'tsserver' then
    vim.keymap.set('n', 'gd', function() vim.cmd(':TypescriptGoToSourceDefinition') end, bufopts)
  else
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  end

  -- TODO: dedupe these + the Trouble maps
  vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<Leader>r', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<Leader>ca', function() vim.cmd(':CodeActionMenu') end, bufopts)

  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, keymap_opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, keymap_opts)

  vim.keymap.set('n', '[e', function()
    vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
  end, keymap_opts)
  vim.keymap.set('n', ']e', function()
    vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
  end, keymap_opts)

  vim.diagnostic.config({
    float = {
      border = 'rounded',
      header = 'Diagnostics',
      source = true,
    },
    virtual_text = {
      prefix = '•',
    },
    signs = false,
  })

  -- TODO: can this be done with  nvim-lspconfig opts = { autoformat = true } ?
  -- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/lsp/init.lua#L28
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

return {
  {
    -- Per-langauge client configs
    'neovim/nvim-lspconfig',
    dependencies = {
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    opts = {
      servers = {
        -- TODO: move this into separate file?
        cssls = {},
        eslint = {},
        html = {},
        jsonls = {},
        lua_ls = {
          -- mason = false, -- set to false if you don't want this server to be installed with mason
          settings = {
            Lua = {
              runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
              },
              diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim' },
              },
              workspace = {
                -- Make the server aware of Neovim runtime files
                library = {
                  vim.api.nvim_get_runtime_file("", true),
                  "${3rd}/luassert/library"
                }
              },
              -- Do not send telemetry data containing a randomized but unique identifier
              telemetry = {
                enable = false,
              },
              format = {
                enable = true,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                }
              }
            },
          },
        },
        pylsp = {},
        rust_analyzer = {},
        svelte = {},
        tailwindcss = {
          filetypes = { "svelte" },
        },
        tsserver = {
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
        },
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
            }
          }
        },
      },
    },
    config = function(_, opts)
      -- Create commands for hiding/showing diagnostic virtual text
      vim.api.nvim_create_user_command('HideDiagnosticVirtualText', function()
        vim.diagnostic.config({ virtual_text = false })
      end, { nargs = 0 })
      vim.api.nvim_create_user_command('ShowDiagnosticVirtualText', function()
        vim.diagnostic.config({ virtual_text = true })
      end, { nargs = 0 })

      require('lspconfig.ui.windows').default_options.border = 'rounded'
      vim.api.nvim_set_hl(0, 'LspInfoBorder', { link = 'Comment' })

      local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

      local servers = opts.servers

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
          on_attach = on_attach,
          handlers = {
            ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' }),
            ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' }),
          }
        }, servers[server] or {})

        -- TODO: do we need this setup block?
        -- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/lsp/init.lua#L54
        -- if opts.setup[server] then
        --   if opts.setup[server](server, server_opts) then return end
        -- elseif opts.setup["*"] then
        --   if opts.setup["*"](server, server_opts) then return end
        -- end

        if server == "tsserver" then
          require("typescript").setup({ server = server_opts })
        else
          require("lspconfig")[server].setup(server_opts)
        end
      end

      local mlsp = require("mason-lspconfig")
      local available = mlsp.get_available_servers()

      local ensure_installed = {}

      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
          if server_opts.mason == false or not vim.tbl_contains(available, server) then
            setup(server)
          else
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end

      require("mason-lspconfig").setup({ ensure_installed = ensure_installed })
      require("mason-lspconfig").setup_handlers({ setup })
    end
  },

  {
    -- LSP server installer
    'williamboman/mason.nvim',
    cmd = 'Mason',
    opts = {
      ui = {
        border = 'rounded',
      }
    }
  },
  {
    -- LSP server installer configs
    'williamboman/mason-lspconfig.nvim',
  },
  {
    -- Show signature help while typing
    'ray-x/lsp_signature.nvim',
    opts = {
      hint_enable = false,
      toggle_key = '<C-h>',
    }
  },

  {
    -- Diagnostic summary plugin
    'folke/trouble.nvim',
    cmd = {
      'Trouble',
      'TroubleClose',
      'TroubleToggle',
    },
    opts = {
      icons = false,
      fold_open = '▾',
      fold_closed = '▸',
      signs = {
        error = '•',
        warning = '•',
        hint = '•',
        information = '•',
      },
      use_diagnostic_signs = false
    },
    keys = {
      { '<Leader>t',  ':TroubleToggle<CR>',                 desc = 'Toggle Trouble' },
      { 'gr',         ':Trouble lsp_references<CR>',        desc = 'Show references' },
      { 'gi',         ':Trouble lsp_implementations<CR>',   desc = 'Show implementations' },
      { '<Leader>fd', ':Trouble document_diagnostics<CR>',  desc = 'Show document diagnostics' },
      { '<Leader>fD', ':Trouble workspace_diagnostics<CR>', desc = 'Show workspace diagnostics' },
    }
  },

  {
    -- Fancy code action menu
    'weilbith/nvim-code-action-menu',
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      vim.g.code_action_menu_show_details = false
      vim.g.code_action_menu_show_action_kind = false
    end
  },

  {
    -- Show lightbulg when code actions available
    'kosayoda/nvim-lightbulb',
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      sign = { enabled = false },
      virtual_text = { enabled = true },
      autocmd = { enabled = true },
    }
  },

  {
    -- Platform for easier LSP features, e.g. formatting and linting
    'jose-elias-alvarez/null-ls.nvim',
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason.nvim" },
    opts = function()
      local nls = require("null-ls")
      return {
        sources = {
          nls.builtins.formatting.prettierd.with({
            config_path = {

            }
          }),
        },
      }
    end,
  },

  {
    'jose-elias-alvarez/typescript.nvim',
    cmd = {
      'TypescriptAddMissingImports',
      'TypescriptOrganizeImport',
      'TypescriptRemoveUnused',
      'TypescriptFixAll',
      'TypescriptRenameFile',
      'TypescriptGoToSourceDefinition',
    },
  }

}
