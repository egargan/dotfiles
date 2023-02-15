-- YAML LSP settings

return function(capabilities, on_attach)
  require('lspconfig')['yamlls'].setup {
      on_attach = on_attach,
      capabilities = capabilities,
  }
end
