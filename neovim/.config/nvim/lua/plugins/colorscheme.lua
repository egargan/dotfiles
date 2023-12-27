return {
  {
    'gbprod/nord.nvim',
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
        highlights["NavicText"] = { fg = colors.polar_night.light, bold = true }
        highlights["NavicIconsFunction"] = { fg = colors.frost.artic_water }
        highlights["NavicIconsNamespace"] = { fg = colors.frost.artic_water }
        highlights["NavicIconsProperty"] = { fg = colors.frost.artic_water }
        highlights["NavicIconsField"] = { fg = colors.frost.artic_water }
        highlights["NavicIconsVariable"] = { fg = colors.frost.artic_water }
        highlights["NavicIconsConstant"] = { fg = colors.frost.artic_water }
        highlights["NavicIconsArray"] = { fg = colors.frost.artic_water }
        highlights["NavicIconsKey"] = { fg = colors.frost.artic_water }
        highlights["NavicIconsNull"] = { fg = colors.frost.artic_water }
        highlights["NavicIconsEnumMember"] = { fg = colors.frost.artic_water }
        highlights["NavicIconsStruct"] = { fg = colors.frost.artic_water }
        highlights["NavicIconsEvent"] = { fg = colors.frost.artic_water }
        highlights["NavicIconsOperator"] = { fg = colors.frost.artic_water }
        highlights["NavicIconsTypeParameter"] = { fg = colors.frost.artic_water }

        -- Noice UI colors
        highlights["NoiceCmdlinePopupBorder"] = { fg = colors.polar_night.brightest }
        highlights["NoiceCmdlinePopupTitle"] = { fg = colors.polar_night.brightest, bold = true }

        -- Symbols outline colours
        -- These aren't standard highlights, they're linked manually in the plugin config
        highlights["FocusedSymbol"] = { fg = colors.frost.ice }
        highlights["SymbolIconFile"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconModule"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconNamespace"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconPackage"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconClass"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconMethod"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconProperty"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconField"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconConstructor"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconEnum"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconInterface"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconFunction"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconVariable"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconConstant"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconString"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconNumber"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconBoolean"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconArray"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconObject"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconKey"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconNull"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconEnumMember"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconStruct"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconEvent"] = { fg = colors.frost.artic_water }
        highlights["SymbolIconOperator"] = { fg = colors.frost.artic_water }

        -- Make colors globally available
        vim.g.nord_colors = colors
      end
    },
    config = function(_, opts)
      require('nord').setup(opts)
      vim.cmd('colorscheme nord')
    end,
    lazy = false
  }
}
