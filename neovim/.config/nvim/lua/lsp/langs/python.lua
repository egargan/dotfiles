-- Python LSP settings

return function(capabilities, on_attach)
  require('lspconfig')['pylsp'].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end
