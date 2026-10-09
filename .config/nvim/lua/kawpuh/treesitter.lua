local ensure_installed = {
  "c", "lua", "rust", "python", "clojure", "vim",
  "fennel", "html", "css", "json", "markdown", "markdown_inline", "scheme",
}

-- Prefer the new parsers and queries over legacy files in the plugin checkout
-- and Neovim's bundled Lua parser.
require('nvim-treesitter').setup {
  install_dir = vim.fn.stdpath('data') .. '/site',
}

-- Parser checks can happen after the editor is usable. Existing parsers are
-- still available immediately to the FileType callback below.
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    vim.schedule(function()
      require('nvim-treesitter').install(ensure_installed)
    end)
  end,
})

require('nvim-treesitter-textobjects').setup {
  select = {
    lookahead = true,
    selection_modes = {
      ['@parameter.outer'] = 'v',
      ['@function.outer'] = 'V',
      ['@class.outer'] = '<c-v>',
    },
    include_surrounding_whitespace = true,
  },
}

local textobjects = {
  af = { '@function.outer', 'textobjects' },
  ['if'] = { '@function.inner', 'textobjects' },
  ac = { '@class.outer', 'textobjects' },
  ic = { '@class.inner', 'textobjects', 'Select inner part of a class region' },
  as = { '@local.scope', 'locals', 'Select language scope' },
}

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

    -- The main branch requires explicit mappings instead of select.keymaps.
    -- Keep Lisp textobjects supplied by vim-sexp for Clojure.
    if filetype ~= 'clojure' then
      for key, object in pairs(textobjects) do
        vim.keymap.set({ 'x', 'o' }, key, function()
          require('nvim-treesitter-textobjects.select').select_textobject(object[1], object[2])
        end, { buffer = buf, desc = object[3] })
      end
    end
  end,
})
