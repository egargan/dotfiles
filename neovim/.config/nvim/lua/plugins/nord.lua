-- Nord colorscheme

return {
  name = 'gbprod/nord.nvim',
  setup = function()

    require("nord").setup({
      diff = { mode = "fg" },
      on_highlights = function(highlights, colors)
        highlights["@parameter"] = { fg = colors.snow_storm.bright }
        highlights["@variable"] = { fg = colors.snow_storm.bright }
        highlights["@punctuation.bracket"] = { fg = colors.frost.artic_water }
        highlights["@punctuation.delimiter"] = { fg = colors.frost.artic_water }

        highlights["DiagnosticUnderlineError"] = { fg = colors.aurora.red, undercurl = true }
        highlights["DiagnosticUnderlineWarn"] = { fg = colors.aurora.yellow, undercurl = true }
        highlights["DiagnosticUnderlineInfo"] = { fg = colors.frost.ice, undercurl = true }
        highlights["DiagnosticUnderlineHint"] = { fg = colors.frost.artic_water, undercurl = true }

      end,
    })

    vim.cmd('colorscheme nord')
  end,
  priority = 1,
}
