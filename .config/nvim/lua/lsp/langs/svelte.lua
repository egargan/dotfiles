return function(capabilities, on_attach)
  require('lspconfig')['svelte'].setup{
    on_attach = on_attach,
    filetypes = { "svelte" },
    capabilities = capabilities,
  }
end
