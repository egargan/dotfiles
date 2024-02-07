-- Set custom globals for LSP features
vim.g.formatting_enabled = true
vim.g.spellcheck_enabled = true

local symbol_icons = {
  File        = "☰",
  Module      = "❖",
  Namespace   = "❖",
  Package     = "❖",
  Class       = "𝑪",
  Method      = "𝒇",
  Property    = "◇",
  Field       = "◇",
  Constructor = "𝒇",
  Enum        = "𝒆",
  Interface   = "𝐼",
  Function    = "𝒇",
  Variable    = "𝑥",
  Constant    = "𝑥",
  String      = '"',
  Number      = "#",
  Boolean     = "𝒃",
  Array       = "[]",
  Object      = "◇",
  Key         = "◇",
  Null        = "ø",
  EnumMember  = "◇",
  Struct      = "𝑺",
  Event       = "ϟ",
  Operator    = "+",
  Component   = "<>",
  Fragment    = "<>",
}

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
    vim.keymap.set('n', 'gd', function() vim.cmd(':TypescriptGoToSourceDefinition') end, map_opts)
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

      local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

      local ensure_installed = {
        'cssls', 'html', 'jsonls', 'lua_ls', 'pylsp', 'svelte', 'tsserver', 'yamlls'
      }

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
      }

      require("mason-lspconfig").setup({ ensure_installed = ensure_installed })
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          require("lspconfig")[server_name].setup(
            vim.tbl_extend('force', {
              capabilities = capabilities,
              on_attach = on_attach,
            }, servers[server_name] or {})
          )
        end,
        ['tsserver'] = function()
          require("typescript").setup({ capabilities = capabilities })
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
      use_diagnostic_signs = false,
      auto_close = true
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
    "stevearc/conform.nvim",
    event = { "BufReadPre" },
    cmd = { "ConformInfo" },
    opts = {
      format_on_save = function(bufnr)
        -- TODO: allow buffer-local flag, with vim.b.formatting_enabled?
        if not vim.g.formatting_enabled then
          return
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        ["markdown"] = { { "prettierd", "prettier" } },
        ["markdown.mdx"] = { { "prettierd", "prettier" } },
        javascript = { { "prettierd", "prettier" } },
        javascriptreact = { { "prettierd", "prettier" } },
        typescript = { { "prettierd", "prettier" } },
        typescriptreact = { { "prettierd", "prettier" } },
        graphql = { { "prettierd", "prettier" } },
        yaml = { { "prettierd", "prettier" } },
        python = { "black" },
        ["_"] = { "trim_whitespace" },
      },
    },
    keys = {
      {
        "<leader>f",
        mode = { "n", "v" },
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        desc = "Format buffer",
      },
    },
  },

  {
    -- Custom LSP sources (linting, code actions, etc)
    'nvimtools/none-ls.nvim',
    event = 'VeryLazy',
    config = function()
      local nls = require("null-ls")

      local common_cspell_config = {
        runtime_condition = function()
          return vim.g.spellcheck_enabled
        end,
        disabled_filetypes = { "NvimTree", "SymbolOutline" },
        config = {
          find_json = vim.schedule(function(cwd)
            local found_cspell = vim.fn.findfile('cspell.json', '.;~')

            if found_cspell ~= '' then return found_cspell end

            if cwd == nil or cwd == '' then
              cwd = vim.fn.getcwd()
            end

            return vim.fn.expand(cwd .. "/cspell.json")
          end)
        }
      }

      local cspell_diags_config = vim.tbl_extend('keep', common_cspell_config, {
        diagnostics_postprocess = function(diagnostic)
          diagnostic.severity = vim.diagnostic.severity.HINT
        end,
      })

      local cspell_code_actions_config = vim.tbl_extend('keep', common_cspell_config, {
        filter = function(action)
          -- filter action if action.title begins with 'Use'
          return action.title:sub(1, 3) ~= "Use"
        end,
      })

      nls.setup({
        sources = {
          nls.builtins.diagnostics.cfn_lint,
          nls.builtins.diagnostics.cspell.with(cspell_diags_config),
          nls.builtins.code_actions.cspell.with(cspell_code_actions_config),
        },
        on_attach = on_attach,
      })

      vim.api.nvim_create_user_command('SpellcheckToggle', function()
        if not vim.g.formatting_enabled then
          vim.g.spellcheck_enabled = true
          require("null-ls").enable({ name = "cspell" })
        else
          vim.g.spellcheck_enabled = false
          require("null-ls").disable({ name = "cspell" })
        end
      end, {
        desc = "Enables or disables cspell spell checking"
      })

      vim.api.nvim_create_user_command('FormattingToggle', function()
        if not vim.g.formatting_enabled then
          vim.g.formatting_enabled = true
        else
          vim.g.formatting_enabled = false
        end
      end, {
        desc = "Enables or disables on-save code formatting"
      })
    end
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
  }
}
