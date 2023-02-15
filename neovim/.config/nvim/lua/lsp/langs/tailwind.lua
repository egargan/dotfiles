-- TailwindCSS LSP Settings

return function(capabilities, on_attach)
  require('lspconfig')['tailwindcss'].setup {
    on_attach = on_attach,
    filetypes = { "svelte" },
    capabilities = capabilities,
  }
end
