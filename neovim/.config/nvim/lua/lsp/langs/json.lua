return function(capabilities, on_attach)
  require('lspconfig')['jsonls'].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end
