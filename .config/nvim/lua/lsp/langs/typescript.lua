-- TypeScript LSP settings

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

require('lspconfig')['tsserver'].setup{
  on_attach = on_attach,
  filetypes = { "typescript", "javascript" },
  capabilities = capabilities,
}
