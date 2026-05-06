local ensure_installed = {
  "c", "lua", "rust", "python", "clojure", "vim",
  "fennel", "html", "css", "json", "markdown", "scheme",
}

require('nvim-treesitter').setup()
require('nvim-treesitter').install(ensure_installed)

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter.setup', {}),
  callback = function(args)
    local buf = args.buf
    local filetype = args.match
    local language = vim.treesitter.language.get_lang(filetype) or filetype
    local ok, added = pcall(vim.treesitter.language.add, language)
    if not ok or not added then
      return
    end
    vim.treesitter.start(buf, language)
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

require('nvim-treesitter-textobjects').setup {
  select = {
    enable = true,
    disable = { 'clojure' },
    lookahead = true,
    keymaps = {
      ["af"] = "@function.outer",
      ["if"] = "@function.inner",
      ["ac"] = "@class.outer",
      ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
      ["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
    },
    selection_modes = {
      ['@parameter.outer'] = 'v',
      ['@function.outer'] = 'V',
      ['@class.outer'] = '<c-v>',
    },
    include_surrounding_whitespace = true,
  },
}
