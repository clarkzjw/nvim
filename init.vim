call plug#begin()
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

" Go
Plug 'ray-x/guihua.lua'
Plug 'ray-x/go.nvim'

" Syntax highlighting
Plug 'nvim-treesitter/nvim-treesitter', { 'branch': 'main', 'do': ':TSUpdate' }

" neo-tree
Plug 'nvim-lua/plenary.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-neo-tree/neo-tree.nvim', { 'branch': 'v3.x' }

" For mini.snippets users.
Plug 'nvim-mini/mini.snippets'
Plug 'rafamadriz/friendly-snippets'
Plug 'abeldekat/cmp-mini-snippets'

" Git
Plug 'petertriho/cmp-git'

call plug#end()

set number
set relativenumber
set mouse=a

autocmd VimEnter * Neotree show

lua <<EOF
  local treesitter_filetypes = {
    'bash',
    'go',
    'gomod',
    'gosum',
    'gotmpl',
    'gowork',
    'json',
    'lua',
    'markdown',
    'markdown_inline',
    'python',
    'toml',
    'vim',
    'vimdoc',
    'yaml',
  }

  vim.api.nvim_create_autocmd('FileType', {
    pattern = treesitter_filetypes,
    callback = function()
      vim.treesitter.start()
    end,
  })

  vim.keymap.set('n', '<C-LeftMouse>', function()
    local mouse = vim.fn.getmousepos()
    if mouse.winid == 0 or mouse.line == 0 or not vim.api.nvim_win_is_valid(mouse.winid) then
      return
    end

    vim.api.nvim_set_current_win(mouse.winid)
    vim.api.nvim_win_set_cursor(mouse.winid, { mouse.line, math.max(mouse.column - 1, 0) })
    vim.lsp.buf.definition()
  end, { desc = 'Go to definition under mouse' })

  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })

  -- Set up nvim-cmp.
  local cmp = require'cmp'
  local snippets = require'mini.snippets'

  snippets.setup({
    snippets = {
      snippets.gen_loader.from_lang(),
    },
  })

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
        insert({ body = args.body })
        cmp.resubscribe({ 'TextChangedI', 'TextChangedP' })
        require('cmp.config').set_onetime({ sources = {} })
      end,
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'mini_snippets' },
    }, {
      { name = 'buffer' },
    })
  })

  -- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'git' },
    }, {
      { name = 'buffer' },
    })
 })
  require('cmp_git').setup()

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    }),
    matching = { disallow_symbol_nonprefix_matching = false }
  })

  -- Set up Go tooling and gopls with completion support.
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  require('go').setup({
    lsp_cfg = false,
    lsp_gofumpt = true,
    goimports = 'gopls',
    gofmt = 'gopls',
    dap_debug = false,
  })

  local gopls_config = require('go.lsp').config()
  gopls_config.capabilities = vim.tbl_deep_extend(
    'force',
    gopls_config.capabilities or {},
    capabilities
  )
  -- gopls v0.16 does not support customizing its semantic-token legend.
  gopls_config.settings.gopls.semanticTokenTypes = nil
  gopls_config.settings.gopls.semanticTokenModifiers = nil
  vim.lsp.config('gopls', gopls_config)
  vim.lsp.enable('gopls')

  vim.lsp.config('pyright', {
    capabilities = capabilities,
  })
  vim.lsp.enable('pyright')

  local go_format_group = vim.api.nvim_create_augroup('GoFormat', { clear = true })
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = go_format_group,
    pattern = '*.go',
    callback = function()
      require('go.format').goimports()
    end,
  })
EOF
