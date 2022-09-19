-- TypeScript LSP settings

return function(capabilities, on_attach)
  require('lspconfig')['tsserver'].setup{
    on_attach = on_attach,
    filetypes = { "typescript", "javascript" },
    capabilities = capabilities,
  }
end
