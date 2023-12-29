-- Set custom formatting global variable
vim.g.formatting_enabled = true

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

  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { noremap = true, silent = true })
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { noremap = true, silent = true })

  vim.keymap.set('n', '[e', function()
    vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
  end, { noremap = true, silent = true })
  vim.keymap.set('n', ']e', function()
    vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
  end, { noremap = true, silent = true })

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
      'nvimtools/none-ls.nvim',
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
        }, servers[server] or {})

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
    -- Show lightbulg when code actions available
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
        mode = "",
        desc = "Format buffer",
      },
    },
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
