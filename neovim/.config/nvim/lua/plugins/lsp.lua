local symbol_icons = require 'lib.lsp-icons'

vim.api.nvim_create_user_command('DiagnosticsToggle', function()
  if vim.diagnostic.is_disabled() then
    vim.diagnostic.enable()
  else
    vim.diagnostic.disable()
  end
end, {
  desc = "Enables or disables LSP diagnostics"
})

-- TODO: break me down, a la
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/lsp/init.lua#L72
local function on_attach(client, bufnr)
  local map_opts = { noremap = true, buffer = bufnr, silent = true }

  if client.name == 'tsserver' then
    vim.keymap.set('n', 'gd', function() vim.cmd(':TSToolsGoToSourceDefinition') end, map_opts)
  else
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, map_opts)
  end

  -- TODO: dedupe these + the Trouble maps
  vim.keymap.set('n', '<leader>k', vim.lsp.buf.hover, map_opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, map_opts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.type_definition, map_opts)
  vim.keymap.set('n', '<Leader>r', vim.lsp.buf.rename, map_opts)
  vim.keymap.set('n', '<Leader>ca', function() vim.cmd(':CodeActionMenu') end, map_opts)

  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, map_opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, map_opts)

  vim.keymap.set('n', '[e', function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end,
    map_opts)
  vim.keymap.set('n', ']e', function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end,
    map_opts)

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

  if client.server_capabilities.documentSymbolProvider then
    require('nvim-navic').attach(client, bufnr)
  end
end

return {
  {
    -- Per-language client configs
    'neovim/nvim-lspconfig',
    dependencies = {
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function(_, opts)
      require('lspconfig.ui.windows').default_options.border = 'rounded'
      vim.api.nvim_set_hl(0, 'LspInfoBorder', { link = 'Comment' })

      local default_capabilities = {}
      local capabilities = vim.tbl_deep_extend(
        "keep",
        default_capabilities,
        require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
      )

      local ensure_installed = {
        'cssls', 'html', 'jsonls', 'lua_ls', 'pylsp', 'svelte', 'tsserver', 'yamlls'
      }

      local svelte_js_change_group = vim.api.nvim_create_augroup(
        "svelte_jschange", { clear = true }
      )

      -- This isn't a list of all enabled servers, just the ones with custom settings!
      -- TODO: can this be typed?
      -- TODO: move this somewhere else?
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = 'LuaJIT' },
              diagnostics = { globals = { 'vim' } },
              workspace = {
                library = { vim.api.nvim_get_runtime_file("", true), "${3rd}/luassert/library" }
              },
              telemetry = { enable = false },
              format = {
                enable = true,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                }
              }
            },
          }
        },
        tailwindcss = {
          root_dir = function(fname)
            return require("lspconfig").util.root_pattern(
              "tailwind.config.cjs",
              "tailwind.config.js",
              "postcss.config.js"
            )(fname)
          end,
        },
        yamlls = {
          settings = {
            yaml = { keyOrdering = false }
          }
        },
        svelte = {
          -- Add custom JS/TS file watcher to tell Svelte to reload types
          -- https://github.com/sveltejs/language-tools/issues/2008
          on_attach = function(client, bufnr)
            vim.api.nvim_create_autocmd("BufWritePost", {
              pattern = { "*.js", "*.ts" },
              group = svelte_js_change_group,
              callback = function(ctx)
                client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
              end,
            })
            on_attach(client, bufnr)
          end,
        }
      }

      require("mason-lspconfig").setup({ ensure_installed = ensure_installed })
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          require("lspconfig")[server_name].setup(
            vim.tbl_extend('force', {
              capabilities = capabilities,
              on_attach = on_attach,
              flags = { debounce_text_changes = 150 }
            }, servers[server_name] or {})
          )
        end,
        ['tsserver'] = function()
          require("typescript-tools").setup({
            capabilities = capabilities,
            on_attach = on_attach,
          })
        end,
      })
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
    },
  },

  {
    -- LSP server installer configs
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'mason.nvim' },
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
      win = {
        size = {
          height = 14,
          width = 40,
        }
      },
      icons = {
        indent = {
          folder_closed = "▸ ",
          folder_open = "▾ ",
        },
        fold_open = '▾',
        fold_closed = '▸',
        kinds = require('lib.lsp-icons'),
      },
      use_diagnostic_signs = false,
      auto_close = true
    },
    keys = {
      { 'gl',         ':Trouble lsp toggle focus=true results.win.size.height=20<CR>',                           desc = 'Show LSP info for symbol' },
      { 'gr',         ':Trouble lsp_references toggle pinned=true focus=true<CR>',                               desc = 'Show references for symbol' },
      { '<Leader>t',  ':Trouble toggle<CR>',                                                                     desc = 'Toggle Trouble' },
      { '<Leader>fs', ':Trouble symbols toggle pinned=true results.win.relative=win results.win.position=right', desc = 'Toggle Trouble' },
      { '<Leader>fd', ':Trouble diagnostics toggle filter.buf=0<CR>',                                            desc = 'Show document diagnostics' },
      { '<Leader>fD', ':Trouble diagnostics toggle<CR>',                                                         desc = 'Show workspace diagnostics' },

      {
        ']q',
        function()
          if require("trouble").is_open() then
            require("trouble").next()
          else
            vim.cmd(':cnext')
          end
        end,
        desc = 'Next in Trouble or quickfix list'
      },
      {
        '[q',
        function()
          if require("trouble").is_open() then
            require("trouble").prev()
          else
            vim.cmd(':cprev')
          end
        end,
        desc = 'Previous in Trouble or quickfix list'
      }
    }
  },

  {
    -- Fancy code action menu
    'weilbith/nvim-code-action-menu',
    event = "LspAttach",
    config = function()
      vim.g.code_action_menu_show_details = false
      vim.g.code_action_menu_show_action_kind = false
    end
  },

  {
    -- Show lightbulb when code actions available
    'kosayoda/nvim-lightbulb',
    event = "LspAttach",
    opts = {
      sign = { enabled = false },
      virtual_text = { enabled = true },
      autocmd = { enabled = true },
    }
  },

  {
    -- A better TS language server
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  },

  {
    'SmiteshP/nvim-navic',
    dependencies = { 'neovim/nvim-lspconfig' },
    event = "LspAttach",
    config = function()
      formatted_icons = {}

      for key, value in pairs(symbol_icons) do
        formatted_icons[key] = value .. ' '
      end

      require('nvim-navic').setup({
        highlight = true,
        icons = formatted_icons,
        separator = " › ",
      })
    end
  },

  {
    -- Outline view of document symbols
    'simrat39/symbols-outline.nvim',
    cmd = {
      'SymbolsOutline',
      'SymbolsOutlineOpen',
      'SymbolsOutlineClose',
    },
    config = function()
      symbols = {}

      for key, value in pairs(symbol_icons) do
        symbols[key] = { icon = value, hl = "SymbolIcon" .. key }
      end

      require('symbols-outline').setup({
        highlight_hovered_item = false,
        width = 20,
        autofold_depth = 3,
        keymaps = {
          close = "q",
          toggle_preview = 'P',
        },
        fold_markers = { '▸', '▾' },
        symbols = symbols,
      })
    end,
  },
}
