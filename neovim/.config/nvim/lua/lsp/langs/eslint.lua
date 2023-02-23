return function(capabilities, on_attach)
  require('lspconfig')['eslint'].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end
