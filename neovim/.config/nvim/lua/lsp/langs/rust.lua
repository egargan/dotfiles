-- Rust LSP settings

return function(capabilities, on_attach)
  require('lspconfig')['rust_analyzer'].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end
