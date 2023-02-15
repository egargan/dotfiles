-- HTML LSP settings

return function(capabilities, on_attach)
  require('lspconfig')['html'].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end
