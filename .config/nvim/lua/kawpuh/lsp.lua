local servers = {
  "bashls",
  "clojure_lsp",
  "clangd",
  "hls",
  "html",
  "cssls",
  "jsonls",
  "racket_langserver",
  "lua_ls",
  "pylsp",
}

for _, lsp in ipairs(servers) do
  vim.lsp.enable(lsp)
  vim.lsp.config(lsp, {
    on_attach = lsp_on_attach,
    flags = {
      debounce_text_changes = 150,
    },
  })
end
