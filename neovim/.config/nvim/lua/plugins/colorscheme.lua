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
      end
    },
    config = function(_, opts)
      require('nord').setup(opts)
      vim.cmd('colorscheme nord')
    end,
    lazy = false
  }
}
