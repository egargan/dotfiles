return {
  {
    'gbprod/nord.nvim',
    opts = {
      comments = { italics = false },
      diff = { mode = "fg" },
      on_highlights = function(highlights, colors)
        highlights["@parameter"] = { fg = colors.snow_storm.bright }
        highlights["@variable"] = { fg = colors.snow_storm.bright }
        highlights["@punctuation.bracket"] = { fg = colors.frost.artic_water }
        highlights["@punctuation.delimiter"] = { fg = colors.frost.artic_water }

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
