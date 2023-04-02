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

        -- Diffview Colors --
        -- (https://github.com/sindrets/diffview.nvim/blob/main/lua/diffview/hl.lua#L352)

        -- Red w/ 30% opacity on polar_night.origin
        highlights["DiffDelete"] = { bg = "#5A424D", fg = "none" }
        highlights["DiffviewDiffAddAsDelete"] = { bg = "none", fg = colors.polar_night.brightest }
        highlights["DiffviewDiffDelete"] = { bg = "none", fg = colors.polar_night.brightest }

        -- Green w/ 20% opacity on polar_night.origin
        highlights["DiffAdd"] = { bg = "#45504F" }
        -- Yellow w/ 20% opacity on polar_night.origin
        highlights["DiffChange"] = { bg = "#54524F" }
        -- Yellow w/ 35% opacity on polar_night.origin
        highlights["DiffText"] = { bg = "#70695A" }
      end
    },
    config = function(_, opts)
      require('nord').setup(opts)
      vim.cmd('colorscheme nord')
    end,
    lazy = false
  }
}
