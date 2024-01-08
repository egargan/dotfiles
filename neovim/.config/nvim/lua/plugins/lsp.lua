-- Set custom globals for LSP features
vim.g.formatting_enabled = true
vim.g.spellcheck_enabled = true

local symbolIcons = {
  file        = "☰",
  module      = "❖",
  namespace   = "❖",
  package     = "❖",
  class       = "𝑪",
  method      = "𝒇",
  property    = "◇",
  field       = "◇",
  constructor = "𝒇",
  enum        = "𝒆",
  interface   = "𝐼",
  func        = "𝒇",
  variable    = "𝑥",
  constant    = "𝑥",
  string      = '"',
  number      = "#",
  boolean     = "𝒃",
  array       = "[]",
  object      = "◇",
  key         = "◇",
  null        = "ø",
  enum_member = "◇",
  struct      = "𝑺",
  event       = "ϟ",
  operator    = "+",
}

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

      -- TODO: move this to top, or separate file? make config? with types?
      local servers = {
        cssls = {},
        eslint = {},
        html = {},
        jsonls = {},
        lua_ls = {
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
        },
        pylsp = {},
        -- rust_analyzer = {},
        svelte = {},
        -- tailwindcss = {},
        tsserver = {},
        yamlls = {
          yaml = { keyOrdering = false }
        },
      }

      require("mason-lspconfig").setup({ ensure_installed = vim.tbl_keys(servers) })
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          require("lspconfig")[server_name].setup({
            capabilities = capabilities,
            on_attach = on_attach,
            settings = servers[server_name]
          })
        end,
        ['tsserver'] = function()
          require("typescript").setup({ capabilities = capabilities })
        end
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
    }
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
    event = { "BufWritePre" },
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
    config = {
      highlight = true,
      icons = {
        File = symbolIcons.file .. ' ',
        Module = symbolIcons.module .. ' ',
        Namespace = symbolIcons.namespace .. ' ',
        Package = symbolIcons.package .. ' ',
        Class = symbolIcons.class .. ' ',
        Method = symbolIcons.method .. ' ',
        Property = symbolIcons.property .. ' ',
        Field = symbolIcons.field .. ' ',
        Constructor = symbolIcons.constructor .. ' ',
        Enum = symbolIcons.enum .. ' ',
        Interface = symbolIcons.interface .. ' ',
        Function = symbolIcons.func .. ' ',
        Variable = symbolIcons.variable .. ' ',
        Constant = symbolIcons.constant .. ' ',
        String = symbolIcons.string .. ' ',
        Number = symbolIcons.number .. ' ',
        Boolean = symbolIcons.boolean .. ' ',
        Array = symbolIcons.array .. ' ',
        Object = symbolIcons.object .. ' ',
        Key = symbolIcons.key .. ' ',
        Null = symbolIcons.null .. ' ',
        EnumMember = symbolIcons.enum_member .. ' ',
        Struct = symbolIcons.struct .. ' ',
        Event = symbolIcons.event .. ' ',
        Operator = symbolIcons.operator .. ' ',
      }
    }
  },

  {
    -- Outline view of document symbols
    'simrat39/symbols-outline.nvim',
    cmd = {
      'SymbolsOutline',
      'SymbolsOutlineOpen',
      'SymbolsOutlineClose',
    },
    opts = {
      highlight_hovered_item = false,
      width = 20,
      autofold_depth = 3,
      keymaps = {
        close = "q",
        toggle_preview = 'P',
      },
      symbols = {
        File = { icon = symbolIcons.file, hl = "SymbolIconFile" },
        Module = { icon = symbolIcons.module, hl = "SymbolIconModule" },
        Namespace = { icon = symbolIcons.namespace, hl = "SymbolIconNamespace" },
        Package = { icon = symbolIcons.package, hl = "SymbolIconPackage" },
        Class = { icon = symbolIcons.class, hl = "SymbolIconClass" },
        Method = { icon = symbolIcons.method, hl = "SymbolIconMethod" },
        Property = { icon = symbolIcons.property, hl = "SymbolIconProperty" },
        Field = { icon = symbolIcons.field, hl = "SymbolIconField" },
        Constructor = { icon = symbolIcons.constructor, hl = "SymbolIconConstructor" },
        Enum = { icon = symbolIcons.enum, hl = "SymbolIconEnum" },
        Interface = { icon = symbolIcons.interface, hl = "SymbolIconInterface" },
        Function = { icon = symbolIcons.func, hl = "SymbolIconFunction" },
        Variable = { icon = symbolIcons.variable, hl = "SymbolIconVariable" },
        Constant = { icon = symbolIcons.constant, hl = "SymbolIconConstant" },
        String = { icon = symbolIcons.string, hl = "SymbolIconString" },
        Number = { icon = symbolIcons.number, hl = "SymbolIconNumber" },
        Boolean = { icon = symbolIcons.boolean, hl = "SymbolIconBoolean" },
        Array = { icon = symbolIcons.array, hl = "SymbolIconArray" },
        Object = { icon = symbolIcons.object, hl = "SymbolIconObject" },
        Key = { icon = symbolIcons.key, hl = "SymbolIconKey" },
        Null = { icon = "NULL", hl = "SymbolIconNull" },
        EnumMember = { icon = symbolIcons.enum_member, hl = "SymbolIconEnumMember" },
        Struct = { icon = symbolIcons.struct, hl = "SymbolIconStruct" },
        Event = { icon = symbolIcons.event, hl = "SymbolIconEvent" },
        Operator = { icon = symbolIcons.operator, hl = "SymbolIconOperator" },
        TypeParameter = { icon = "𝙏", hl = "SymbolIconTypeParameter" },
        Component = { icon = "", hl = "SymbolIconComponent" },
        Fragment = { icon = "", hl = "SymbolIconFragment" },
      },
      fold_markers = { '▸', '▾' },
    }
  }
}
