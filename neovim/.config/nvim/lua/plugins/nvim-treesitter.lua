-- Plugin dev-oriented tree sitter library

local hl = function(group, opts)
  opts.default = true
  vim.api.nvim_set_hl(0, group, opts)
end

function setup()
  require('nvim-treesitter.configs').setup({
    highlight = {
      enable = true,
    },
    indent = {
      enable = true
    },
    ensure_installed = { "svelte", "typescript", "lua", "html", "scss", "python", "yaml", "json", "query", "javascript" },
  })

  -- Links new highlight groups to old 'obsolete' ones, that were deprecated in 42ab95d.
  -- These are temporary. Eventaully, Nord should provide these highlights themselves.
  -- See https://github.com/nvim-treesitter/nvim-treesitter/issues/2293#issuecomment-1279974776
  -- Code from https://github.com/nvim-treesitter/nvim-treesitter/commit/42ab95d5e11f247c6f0c8f5181b02e816caa4a4f#commitcomment-87014462

  -- Misc {{{
  hl('@comment', {link = 'Comment'})
  -- hl('@error', {link = 'Error'})
  hl('@none', {bg = 'NONE', fg = 'NONE'})
  hl('@preproc', {link = 'PreProc'})
  hl('@define', {link = 'Define'})
  hl('@operator', {link = 'Operator'})
  -- }}}

  -- Punctuation {{{
  hl('@punctuation.delimiter', {link = 'Delimiter'})
  hl('@punctuation.bracket', {link = 'Delimiter'})
  hl('@punctuation.special', {link = 'Delimiter'})
  -- }}}

  -- Literals {{{
  hl('@string', {link = 'String'})
  hl('@string.regex', {link = 'String'})
  hl('@string.escape', {link = 'SpecialChar'})
  hl('@string.special', {link = 'SpecialChar'})

  hl('@character', {link = 'Character'})
  hl('@character.special', {link = 'SpecialChar'})

  hl('@boolean', {link = 'Boolean'})
  hl('@number', {link = 'Number'})
  hl('@float', {link = 'Float'})
  -- }}}

  -- Functions {{{
  hl('@function', {link = 'Function'})
  hl('@function.call', {link = 'Function'})
  hl('@function.builtin', {link = 'Special'})
  hl('@function.macro', {link = 'Macro'})

  hl('@method', {link = 'Function'})
  hl('@method.call', {link = 'Function'})

  hl('@constructor', {link = 'Special'})
  hl('@parameter', {link = 'Identifier'})
  -- }}}

  -- Keywords {{{
  hl('@keyword', {link = 'Keyword'})
  hl('@keyword.function', {link = 'Keyword'})
  hl('@keyword.operator', {link = 'Keyword'})
  hl('@keyword.return', {link = 'Keyword'})

  hl('@conditional', {link = 'Conditional'})
  hl('@repeat', {link = 'Repeat'})
  hl('@debug', {link = 'Debug'})
  hl('@label', {link = 'Label'})
  hl('@include', {link = 'Include'})
  hl('@exception', {link = 'Exception'})
  -- }}}

  -- Types {{{
  hl('@type', {link = 'Type'})
  hl('@type.builtin', {link = 'Type'})
  hl('@type.qualifier', {link = 'Type'})
  hl('@type.definition', {link = 'Typedef'})

  hl('@storageclass', {link = 'StorageClass'})
  hl('@attribute', {link = 'PreProc'})
  hl('@field', {link = 'Identifier'})
  hl('@property', {link = 'Identifier'})
  -- }}}

  -- Identifiers {{{
  hl('@variable', {link = 'Normal'})
  hl('@variable.builtin', {link = 'Special'})

  hl('@constant.builtin', {link = 'Special'})
  hl('@constant.macro', {link = 'Define'})

  hl('@namespace', {link = 'Include'})
  hl('@symbol', {link = 'Identifier'})
  -- }}}

  -- Text {{{
  hl('@text', {link = 'Normal'})
  hl('@text.strong', {bold = true})
  hl('@text.emphasis', {italic = true})
  hl('@text.underline', {underline = true})
  hl('@text.strike', {strikethrough = true})
  hl('@text.title', {link = 'Title'})
  hl('@text.literal', {link = 'String'})
  hl('@text.uri', {link = 'Underlined'})
  hl('@text.math', {link = 'Special'})
  hl('@text.environment', {link = 'Macro'})
  hl('@text.environment.name', {link = 'Type'})
  hl('@text.reference', {link = 'Constant'})

  hl('@text.todo', {link = 'Todo'})
  hl('@text.note', {link = 'SpecialComment'})
  hl('@text.warning', {link = 'WarningMsg'})
  hl('@text.danger', {link = 'ErrorMsg'})
  -- }}}

  -- Tags {{{
  hl('@tag', {link = 'Statement'})
  hl('@tag.attribute', {link = 'Function'})
  hl('@tag.delimiter', {link = 'Statement'})
  -- }}}

  -- Custom {{{
  hl('@doctype', {link = 'Comment'})
  hl('@constant', {link = 'Comment'})
  -- }}}
end

return {
  name = 'nvim-treesitter/nvim-treesitter',
  options = { ['do'] = ':TSUpdate' },
  setup = setup,
  priority = 2,
}
