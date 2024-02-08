-- Install Lazy plugin manager if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

return function(plugin_paths)
  local spec = vim.tbl_map(function(path)
    return { import = path }
  end, plugin_paths)

  -- Setup plugins, including LSP and completion config
  -- TODO: load subset when running with viq
  require("lazy").setup({
    spec = spec,
    ui = {
      border = "rounded",
    },
    change_detection = {
      enabled = false,
    },
  })
end
