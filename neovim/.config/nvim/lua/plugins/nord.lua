return {
  {
    'gbprod/nord.nvim',
    lazy = false,
    opts = {
      comments = { italics = false },
      diff = { mode = "fg" },
      on_highlights = function(highlights, colors)
        -- use 'ctermfg = White' to hide underline for diff highlight
        -- (https://github.com/neovim/neovim/issues/9800)
        highlights["CursorLine"] = { ctermfg = "White", bg = colors.polar_night.bright, blend = 50 }

        highlights["@parameter"] = { fg = colors.snow_storm.bright }
        highlights["@variable"] = { fg = colors.snow_storm.bright }
        highlights["@punctuation.bracket"] = { fg = colors.frost.artic_water }
        highlights["@punctuation.delimiter"] = { fg = colors.frost.artic_water }

        highlights["@error"] = { fg = colors.aurora.red, bg = '' }
        highlights["Error"] = { fg = colors.aurora.red, bg = '' }
        highlights["ErrorMsg"] = { fg = colors.aurora.red, bg = '' }
        highlights["WarningMsg"] = { fg = colors.aurora.yellow, bg = '' }

        highlights["LspReferenceText"] = { bg = colors.polar_night.brightest }
        highlights["LspReferenceRead"] = { bg = colors.polar_night.brightest }
        highlights["LspReferenceWrite"] = { bg = colors.polar_night.brightest }

        highlights["NvimTreeOpenedFolderName"] = { fg = colors.frost.ice }

        highlights["DiagnosticUnderlineError"] = vim.tbl_extend("keep",
          highlights["DiagnosticVirtualTextError"], { undercurl = true })
        highlights["DiagnosticUnderlineWarn"] = vim.tbl_extend("keep",
          highlights["DiagnosticVirtualTextWarn"], { undercurl = true })
        highlights["DiagnosticUnderlineInfo"] = vim.tbl_extend("keep",
          highlights["DiagnosticVirtualTextInfo"], { undercurl = true })
        highlights["DiagnosticUnderlineHint"] = vim.tbl_extend("keep",
          highlights["DiagnosticVirtualTextHint"], { undercurl = true })

        highlights["Folded"] = { fg = colors.polar_night.brightest }

        -- DiffView
        highlights["DiffviewStatusModified"] = { fg = colors.aurora.yellow }
        highlights["DiffviewFilePanelInsertions"] = { fg = colors.aurora.green }
        highlights["DiffviewFilePanelDeletions"] = { fg = colors.aurora.red }
        highlights["DiffviewSecondary"] = { fg = colors.frost.ice }
        highlights["DiffviewFilePanelSelected"] = { bg = "none", fg = colors.snow_storm.brighter, bold = true }
        -- highlights["DiffviewFolderName"] = { link = "DiffviewDim1" }
        -- Red w/ 30% opacity on polar_night.origin
        highlights["DiffDelete"] = { bg = "#4B3D48", fg = "none" }
        highlights["DiffviewDiffAddAsDelete"] = { bg = "none", fg = colors.polar_night.brightest }
        highlights["DiffviewDiffDelete"] = { bg = "none", fg = colors.polar_night.brightest }
        -- Green w/ 20% opacity on aurora.green
        highlights["DiffAdd"] = { bg = "#40494B" }
        -- Yellow w/ 20% opacity on aurora.yellow
        highlights["DiffChange"] = { bg = "#414347" }
        -- Yellow w/ 35% opacity on aurora.yellow
        highlights["DiffText"] = { bg = "#54524F" }

        -- Gitsigns
        highlights["GitSignsAddPreview"] = { fg = colors.aurora.green }
        highlights["GitSignsDeletePreview"] = { fg = colors.aurora.red }

        -- nvim-code-action-menu
        highlights["CodeActionMenuDetailsCreatedFile"] = { fg = colors.aurora.green }
        highlights["CodeActionMenuDetailsChangedFile"] = { fg = colors.aurora.yellow }
        highlights["CodeActionMenuDetailsRenamedFile"] = { fg = colors.aurora.yellow }
        highlights["CodeActionMenuDetailsDeletedFile"] = { fg = colors.aurora.red }
        highlights["CodeActionMenuDetailsAddedLinesCount"] = { fg = colors.aurora.green }
        highlights["CodeActionMenuDetailsDeletedLinesCount"] = { fg = colors.aurora.red }
        highlights["CodeActionMenuDetailsAddedLine"] = { fg = colors.aurora.green }
        highlights["CodeActionMenuDetailsDeletedLine"] = { fg = colors.aurora.red }

        -- nvim-navic colors
        -- https://github.com/SmiteshP/nvim-navic#-customise
        highlights["NavicSeparator"] = { fg = colors.polar_night.brightest, bold = true }
        highlights["NavicText"] = { fg = '#A6AFC2' } -- custom mid-grey color
        highlights['NavicIconsFile'] = highlights['@type']
        highlights['NavicIconsModule'] = highlights['@type']
        highlights["NavicIconsNamespace"] = highlights['@type']
        highlights['NavicIconsPackage'] = highlights['@type']
        highlights['NavicIconsClass'] = highlights['@type']
        highlights['NavicIconsMethod'] = highlights['@function']
        highlights['NavicIconsProperty'] = highlights['@constant.builtin']
        highlights['NavicIconsField'] = highlights['@constant.builtin']
        highlights['NavicIconsConstructor'] = highlights['@constructor']
        highlights['NavicIconsEnum'] = highlights['@type']
        highlights['NavicIconsInterface'] = highlights['@type']
        highlights['NavicIconsFunction'] = highlights['@function']
        highlights['NavicIconsVariable'] = highlights['@variable.builtin']
        highlights['NavicIconsConstant'] = highlights['@constant.builtin']
        highlights['NavicIconsString'] = highlights['@string']
        highlights['NavicIconsNumber'] = highlights['@number']
        highlights['NavicIconsBoolean'] = highlights['@boolean']
        highlights['NavicIconsArray'] = highlights['@number']
        highlights['NavicIconsObject'] = highlights['@constant.builtin']
        highlights['NavicIconsKey'] = highlights['@constant.builtin']
        highlights['NavicIconsNull'] = highlights['@constant.builtin']
        highlights['NavicIconsEnumMember'] = highlights['@constant.builtin']
        highlights['NavicIconsStruct'] = highlights['@type']
        highlights['NavicIconsEvent'] = highlights['@character.special']
        highlights['NavicIconsOperator'] = highlights['@operator']
        highlights['NavicIconsTypeParameter'] = highlights['@type']

        -- Noice UI colors
        highlights["NoiceCmdlinePopupBorder"] = { fg = colors.polar_night.brightest }
        highlights["NoiceCmdlinePopupTitle"] = { fg = colors.polar_night.brightest, bold = true }

        -- Symbols outline colours
        -- These aren't standard highlights, they're linked manually in the plugin config
        highlights["FocusedSymbol"] = { fg = colors.frost.ice }
        highlights["SymbolIconFile"] = highlights['@type']
        highlights["SymbolIconModule"] = highlights['@type']
        highlights["SymbolIconNamespace"] = highlights['@type']
        highlights["SymbolIconPackage"] = highlights['@type']
        highlights["SymbolIconClass"] = highlights['@type']
        highlights["SymbolIconMethod"] = highlights['@function']
        highlights["SymbolIconProperty"] = highlights['@constant.builtin']
        highlights["SymbolIconField"] = highlights['@constant.builtin']
        highlights["SymbolIconConstructor"] = highlights['@constructor']
        highlights["SymbolIconEnum"] = highlights['@type']
        highlights["SymbolIconInterface"] = highlights['@type']
        highlights["SymbolIconFunction"] = highlights['@function']
        highlights["SymbolIconVariable"] = highlights['@variable.builtin']
        highlights["SymbolIconConstant"] = highlights['@constant.builtin']
        highlights["SymbolIconString"] = highlights['@string']
        highlights["SymbolIconNumber"] = highlights['@number']
        highlights["SymbolIconBoolean"] = highlights['@boolean']
        highlights["SymbolIconArray"] = highlights['number']
        highlights["SymbolIconObject"] = highlights['@constant.builtin']
        highlights["SymbolIconKey"] = highlights['@constant.builtin']
        highlights["SymbolIconNull"] = highlights['@constant.builtin']
        highlights["SymbolIconEnumMember"] = highlights['@constant.builtin']
        highlights["SymbolIconStruct"] = highlights['@type']
        highlights["SymbolIconEvent"] = highlights['@character.special']
        highlights["SymbolIconOperator"] = highlights['@operator']

        -- Glance
        highlights["GlanceListMatch"] = highlights['CmpItemAbbrMatch']
        -- Use custom background colour between polar_night.origin and polar_night.bright
        highlights["GlanceListNormal"] = { bg = "#333947" }
        highlights["GlanceListEndOfBuffer"] = { bg = "#333947" }

        -- Make colors globally available
        vim.g.nord_colors = colors
      end
    },
    config = function(_, opts)
      require('nord').setup(opts)
      vim.cmd('colorscheme nord')
    end,
  }
}
