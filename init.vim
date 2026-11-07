call plug#begin()
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'windwp/nvim-autopairs'
Plug 'stevearc/conform.nvim'

" Go
Plug 'ray-x/guihua.lua'
Plug 'ray-x/go.nvim'

" Syntax highlighting
Plug 'nvim-treesitter/nvim-treesitter', { 'branch': 'main', 'do': ':TSUpdate' }
Plug 'rebelot/kanagawa.nvim'
Plug 'lervag/vimtex'

" neo-tree
Plug 'nvim-lua/plenary.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'folke/snacks.nvim'
Plug 'nvim-neo-tree/neo-tree.nvim', { 'branch': 'v3.x' }

" Search and sessions
Plug 'nvim-telescope/telescope.nvim'
Plug 'rmagatti/auto-session'
Plug 'akinsho/toggleterm.nvim', { 'tag': '*' }
Plug 'nanozuki/tabby.nvim'

" For mini.snippets users.
Plug 'nvim-mini/mini.snippets'
Plug 'rafamadriz/friendly-snippets'
Plug 'abeldekat/cmp-mini-snippets'

" Git
Plug 'petertriho/cmp-git'
Plug 'kdheepak/lazygit.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'lewis6991/satellite.nvim'

" typst
Plug 'chomosuke/typst-preview.nvim', {'tag': 'v1.*'}

call plug#end()

filetype plugin indent on
syntax enable

set number
" set relativenumber
set mouse=a
set termguicolors
set hidden
set timeoutlen=2000

let g:vimtex_compiler_method = 'latexmk'
let g:vimtex_view_method = 'skim'
let g:vimtex_view_skim_sync = 1
let g:vimtex_view_skim_activate = 0
let g:vimtex_quickfix_mode = 0
let g:vimtex_main_choose_first = 1

lua <<EOF
  vim.opt.autoread = true

  local auto_reload_group = vim.api.nvim_create_augroup('AutoReloadFromDisk', { clear = true })
  vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
    group = auto_reload_group,
    command = 'checktime',
    desc = 'Reload files changed outside Neovim',
  })

  vim.keymap.set({ 'n', 'i', 'x' }, '<C-s>', '<cmd>write<CR>', { desc = 'Save file' })
  vim.keymap.set({ 'n', 'i', 'x' }, '<D-s>', '<cmd>write<CR>', { desc = 'Save file' })
  vim.keymap.set({ 'n', 'i', 'x' }, '<D-z>', '<cmd>undo<CR>', { desc = 'Undo' })

  local kanagawa_ok, kanagawa = pcall(require, 'kanagawa')
  if kanagawa_ok then
    kanagawa.setup({
      commentStyle = { italic = true },
      functionStyle = { bold = true },
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      terminalColors = true,
      theme = 'wave',
      overrides = function(colors)
        return {
          CmpDocumentation = { bg = colors.palette.sumiInk0 },
          CmpDocumentationBorder = {
            fg = colors.palette.crystalBlue,
            bg = colors.palette.sumiInk0,
          },
        }
      end,
    })
    vim.cmd.colorscheme('kanagawa-wave')
  end

  require('gitsigns').setup()
  require('satellite').setup()

  require 'typst-preview'.setup {
  -- Setting this true will enable logging debug information to
  -- `vim.fn.stdpath 'data' .. '/typst-preview/log.txt'`
  debug = false,

  -- Custom format string to open the output link provided with %s
  -- Example: open_cmd = 'firefox %s -P typst-preview --class typst-preview'
  open_cmd = nil,

  -- Custom port to open the preview server. Default is random.
  -- Example: port = 8000
  port = 0,

  -- Custom host to bind the preview server to.
  -- Note that '0.0.0.0' is not supported and [won't be](https://github.com/Myriad-Dreamin/tinymist/issues/2105)
  -- Example: host = '192.168.0.10'
  host = '127.0.0.1',

  -- Setting this to 'always' will invert black and white in the preview
  -- Setting this to 'auto' will invert depending if the browser has enable
  -- dark mode
  -- Setting this to '{"rest": "<option>","image": "<option>"}' will apply
  -- your choice of color inversion to images and everything else
  -- separately.
  invert_colors = 'never',

  -- Only render the visible portion of the document.
  -- Improves performance significantly for large documents.
  -- Disable if you experience rendering issues.
  partial_rendering = true,

  -- Whether the preview will follow the cursor in the source file
  follow_cursor = true,

  -- Provide the path to binaries for dependencies.
  -- Setting this will skip the download of the binary by the plugin.
  -- Warning: Be aware that your version might be older than the one
  -- required.
  dependencies_bin = {
    tinymist = nil,
    websocat = nil
  },

  -- A list of extra arguments (or nil) to be passed to previewer.
  -- For example, extra_args = { "--input=ver=draft", "--ignore-system-fonts" }
  extra_args = nil,

  -- This function will be called to determine the root of the typst project
  get_root = function(path_of_main_file)
    local root = os.getenv 'TYPST_ROOT'
    if root then
      return root
    end

    -- A Git repository can contain multiple Typst projects, so only an explicit
    -- Typst manifest should override the main file's directory.
    local main_dir = vim.fs.dirname(vim.fn.fnamemodify(path_of_main_file, ':p'))
    local found = vim.fs.find('typst.toml', { path = main_dir, upward = true })
    if #found > 0 then
      return vim.fs.dirname(found[1])
    end

    return main_dir
  end,

  -- This function will be called to determine the main file of the typst
  -- project.
  get_main_file = function(path_of_buffer)
    return path_of_buffer
  end,
  }

  require('snacks').setup({
    image = {
      enabled = true,
      formats = { 'png', 'jpg', 'jpeg', 'pdf' },
      doc = {
        enabled = false,
      },
    },
  })

  local image_placements = {}
  local snacks_image_buf = require('snacks.image.buf')
  local snacks_image_attach = snacks_image_buf._attach
  snacks_image_buf._attach = function(buf, opts)
    local placement = snacks_image_attach(buf, opts)
    image_placements[buf] = placement
    return placement
  end

  local image_reopen_group = vim.api.nvim_create_augroup('ImageReopen', { clear = true })
  vim.api.nvim_create_autocmd('BufEnter', {
    group = image_reopen_group,
    pattern = { '*.png', '*.jpg', '*.jpeg', '*.pdf' },
    callback = function(event)
      local placement = image_placements[event.buf]
      if placement and placement.hidden then
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(event.buf) then
            placement:show()
          end
        end)
      end
    end,
    desc = 'Restore an image placement when reopening its buffer',
  })
  vim.api.nvim_create_autocmd({ 'BufDelete', 'BufWipeout' }, {
    group = image_reopen_group,
    callback = function(event)
      image_placements[event.buf] = nil
    end,
  })

  require('conform').setup({
    formatters_by_ft = {
      python = { 'ruff_fix', 'ruff_format' },
    },
    format_on_save = function(bufnr)
      if vim.bo[bufnr].filetype == 'python' then
        return { timeout_ms = 1000, lsp_format = 'never' }
      end
    end,
  })

  require('neo-tree').setup({
    default_component_configs = {
      last_modified = {
        enabled = false,
      },
      type = {
        enabled = false,
      },
    },
    event_handlers = {
      {
        event = 'neo_tree_buffer_enter',
        handler = function()
          vim.wo.wrap = true
        end,
      },
    },
    filesystem = {
      use_libuv_file_watcher = true,
      filtered_items = {
        visible = true,
      },
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
    },
  })

  local function open_telescope_selections_in_tabs(prompt_bufnr)
    local action_state = require('telescope.actions.state')
    local actions = require('telescope.actions')
    local picker = action_state.get_current_picker(prompt_bufnr)
    local selections = picker:get_multi_selection()

    if #selections == 0 then
      local selected = action_state.get_selected_entry()
      if not selected then
        return
      end
      selections = { selected }
    end

    local cwd = picker.cwd or vim.uv.cwd()
    actions.close(prompt_bufnr)
    for _, entry in ipairs(selections) do
      local filename
      if entry.bufnr then
        vim.cmd('tab sbuffer ' .. entry.bufnr)
        filename = vim.api.nvim_buf_get_name(entry.bufnr)
      else
        filename = entry.path or entry.filename or entry.value
        if type(filename) == 'string' then
          filename = vim.fs.abspath(filename, { base = cwd })
          vim.cmd('tabedit ' .. vim.fn.fnameescape(filename))
        end
      end

      if type(filename) == 'string' and filename ~= '' then
        require('neo-tree.command').execute({
          action = 'show',
          source = 'filesystem',
          reveal_file = filename,
        })
        -- Neo-tree debounces filesystem scans across tabs.
        vim.wait(120)
      end
    end
  end

  require('telescope').setup({
    defaults = {
      path_display = { 'smart' },
    },
    pickers = {
      find_files = {
        hidden = true,
        no_ignore = false,
        mappings = {
          i = {
            ['<C-t>'] = open_telescope_selections_in_tabs,
          },
          n = {
            ['<C-t>'] = open_telescope_selections_in_tabs,
          },
        },
      },
    },
  })
  require('telescope').load_extension('lazygit')

  local telescope_builtin = require('telescope.builtin')
  vim.keymap.set('n', '<leader>ff', telescope_builtin.find_files, { desc = 'Find files' })
  vim.keymap.set('n', '<leader>fg', telescope_builtin.live_grep, { desc = 'Live grep' })
  vim.keymap.set('n', '<leader>fb', telescope_builtin.buffers, { desc = 'Find buffers' })
  vim.keymap.set('n', '<leader>fh', telescope_builtin.help_tags, { desc = 'Find help' })

  local neo_tree_session_state

  local function save_neo_tree_state()
    local state = require('neo-tree.sources.manager').get_state('filesystem')
    if not state.tree then
      return
    end

    return vim.json.encode({
      path = state.path,
      expanded = require('neo-tree.ui.renderer').get_expanded_nodes(state.tree),
    })
  end

  local function restore_neo_tree_state(_, extra_data)
    local ok, state = pcall(vim.json.decode, extra_data)
    if ok then
      neo_tree_session_state = state
    end
  end

  local function open_neo_tree()
    local file_window = vim.api.nvim_get_current_win()

    if not neo_tree_session_state then
      vim.cmd('Neotree reveal')
    else
      local manager = require('neo-tree.sources.manager')
      local state = manager.get_state('filesystem')
      state.force_open_folders = neo_tree_session_state.expanded
      require('neo-tree.command').execute({
        action = 'show',
        source = 'filesystem',
        dir = neo_tree_session_state.path,
      })
      neo_tree_session_state = nil
    end

    if vim.api.nvim_win_is_valid(file_window) then
      vim.api.nvim_set_current_win(file_window)
    end
  end

  local function preserve_file_window()
    local windows = vim.api.nvim_list_wins()
    if #windows ~= 1 or vim.bo[vim.api.nvim_win_get_buf(windows[1])].filetype ~= 'neo-tree' then
      return
    end

    local buffers = vim.fn.getbufinfo({ buflisted = 1 })
    table.sort(buffers, function(a, b)
      return a.lastused > b.lastused
    end)
    for _, buffer in ipairs(buffers) do
      if buffer.name ~= '' and vim.fn.filereadable(buffer.name) == 1 then
        local neo_tree_window = windows[1]
        vim.cmd('new')
        vim.api.nvim_win_set_buf(0, buffer.bufnr)
        vim.api.nvim_win_close(neo_tree_window, true)
        return
      end
    end
  end

  -- Plugin-local mappings are recreated by filetype plugins. Serializing them can
  -- produce executable fragments such as VimTeX's operator-pending `g@` mapping.
  vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos'
  require('auto-session').setup({
    suppressed_dirs = { '~/', '/' },
    save_extra_data = save_neo_tree_state,
    restore_extra_data = restore_neo_tree_state,
    pre_save_cmds = { preserve_file_window },
    post_restore_cmds = { open_neo_tree },
    no_restore_cmds = { open_neo_tree },
    session_lens = {
      picker = 'telescope',
    },
  })

  vim.keymap.set('n', '<leader>wr', '<cmd>AutoSession search<CR>', { desc = 'Search sessions' })
  vim.keymap.set('n', '<leader>ws', '<cmd>AutoSession save<CR>', { desc = 'Save session' })
  vim.keymap.set('n', '<leader>wd', '<cmd>AutoSession delete<CR>', { desc = 'Delete session' })

  vim.o.showtabline = 2
  require('tabby').setup({
    preset = 'tab_only',
    option = {
      nerdfont = true,
      buf_name = {
        mode = 'tail',
      },
    },
  })
  vim.keymap.set('n', '<leader>tT', '<cmd>Tabby jump_to_tab<CR>', { desc = 'Jump to tab' })

  require('toggleterm').setup({
    size = function(terminal)
      if terminal.direction == 'horizontal' then
        return 15
      elseif terminal.direction == 'vertical' then
        return math.floor(vim.o.columns * 0.4)
      end
    end,
    start_in_insert = true,
    persist_size = true,
    persist_mode = true,
    close_on_exit = true,
    float_opts = {
      border = 'curved',
    },
  })

  local toggleterm_terminal = require('toggleterm.terminal')
  local toggleterm_ui = require('toggleterm.ui')
  local tab_terminals = {}

  local function toggle_terminal(terminal, direction, tabpage)
    if direction ~= 'horizontal' and direction ~= 'vertical' then
      terminal:toggle(nil, direction)
      return
    end

    local find_open_windows = toggleterm_ui.find_open_windows
    toggleterm_ui.find_open_windows = function(comparator)
      local _, windows = find_open_windows(comparator)
      local tab_windows = vim.tbl_filter(function(item)
        return vim.api.nvim_win_get_tabpage(item.window) == tabpage
      end, windows)
      return #tab_windows > 0, tab_windows
    end

    local ok, error_message = pcall(terminal.toggle, terminal, nil, direction)
    toggleterm_ui.find_open_windows = find_open_windows
    if not ok then
      error(error_message)
    end
  end

  local function map_terminal(lhs, role, direction, name, description)
    vim.keymap.set({ 'n', 't' }, lhs, function()
      local _, focused = toggleterm_terminal.identify()
      if focused and focused:is_focused() and focused.mapped_role == role then
        focused:close()
        return
      end

      local tabpage = vim.api.nvim_get_current_tabpage()
      tab_terminals[tabpage] = tab_terminals[tabpage] or {}
      local requested = tab_terminals[tabpage][role]
      if requested and requested.bufnr and not vim.api.nvim_buf_is_valid(requested.bufnr) then
        requested = nil
      end

      if not requested then
        requested = toggleterm_terminal.Terminal:new({
          direction = direction,
          display_name = name,
        })
        requested.mapped_role = role
        tab_terminals[tabpage][role] = requested
      end

      toggle_terminal(requested, direction, tabpage)
    end, { desc = description })
  end

  map_terminal('<leader>tt', 'tab', 'tab', 'tab', 'Terminal in tab')
  map_terminal('<leader>tb', 'below', 'horizontal', 'below', 'Terminal below')
  map_terminal('<leader>tv', 'vertical', 'vertical', 'vertical', 'Terminal on right')
  map_terminal('<leader>tf', 'float', 'float', 'float', 'Floating terminal')

  vim.api.nvim_create_autocmd('TermOpen', {
    pattern = 'term://*toggleterm#*',
    callback = function(event)
      vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', {
        buffer = event.buf,
        desc = 'Leave terminal mode',
      })
    end,
  })

  vim.api.nvim_create_autocmd('BufEnter', {
    pattern = 'term://*toggleterm#*',
    callback = function(event)
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(event.buf) and vim.api.nvim_get_current_buf() == event.buf then
          vim.cmd.startinsert()
        end
      end)
    end,
    desc = 'Enter terminal mode when focusing ToggleTerm',
  })

  vim.g.lazygit_floating_window_scaling_factor = 0.9
  vim.g.lazygit_floating_window_use_plenary = 1
  vim.keymap.set('n', '<leader>gg', '<cmd>LazyGitCurrentFile<CR>', { desc = 'Open LazyGit' })
  vim.keymap.set('n', '<leader>gl', '<cmd>Telescope lazygit<CR>', { desc = 'Find Git repositories' })

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
      -- A missing or stale parser must not abort FileType and block LSP startup.
      pcall(vim.treesitter.start)
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
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })

  local unused_function_namespace = vim.api.nvim_create_namespace('UnusedFunctions')
  local unused_function_group = vim.api.nvim_create_augroup('UnusedFunctions', { clear = true })
  local unused_function_codes = {
    ['reportUnusedFunction'] = true,
    ['unused-function'] = true,
    ['unusedfunc'] = true,
  }

  local function set_unused_function_highlight()
    vim.api.nvim_set_hl(0, 'UnusedFunction', { fg = '#727169' })
  end

  set_unused_function_highlight()
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = unused_function_group,
    callback = set_unused_function_highlight,
    desc = 'Keep unused functions gray after changing colorschemes',
  })

  vim.api.nvim_create_autocmd('DiagnosticChanged', {
    group = unused_function_group,
    callback = function(event)
      local bufnr = event.buf
      vim.api.nvim_buf_clear_namespace(bufnr, unused_function_namespace, 0, -1)

      for _, diagnostic in ipairs(vim.diagnostic.get(bufnr)) do
        local lsp_diagnostic = diagnostic.user_data and diagnostic.user_data.lsp or {}
        local code = tostring(diagnostic.code or lsp_diagnostic.code or '')
        local source = tostring(diagnostic.source or lsp_diagnostic.source or '')
        local message = diagnostic.message:lower()
        local is_unused_function = unused_function_codes[code]
          or unused_function_codes[source]
          or (code == 'U1000' and message:match('^func.- is unused'))

        if is_unused_function then
          vim.api.nvim_buf_set_extmark(bufnr, unused_function_namespace, diagnostic.lnum, diagnostic.col, {
            end_row = diagnostic.end_lnum,
            end_col = diagnostic.end_col,
            hl_group = 'UnusedFunction',
            priority = 150,
          })
        end
      end
    end,
    desc = 'Gray out function names reported as unused',
  })

  -- Set up nvim-cmp.
  local cmp = require'cmp'
  local snippets = require'mini.snippets'

  snippets.setup({
    snippets = {
      snippets.gen_loader.from_lang(),
    },
  })
  require('nvim-autopairs').setup({})

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
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<CR>'] = cmp.mapping.confirm({ select = false }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'mini_snippets' },
    }, {
      { name = 'buffer' },
    })
  })
  cmp.event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done())

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

  vim.lsp.config('bashls', {
    capabilities = capabilities,
  })
  vim.lsp.enable('bashls')

  vim.lsp.config('texlab', {
    capabilities = capabilities,
    settings = {
      texlab = {
        build = {
          onSave = false,
        },
        chktex = {
          onOpenAndSave = true,
          onEdit = false,
        },
      },
    },
  })
  vim.lsp.enable('texlab')

  local go_format_group = vim.api.nvim_create_augroup('GoFormat', { clear = true })
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = go_format_group,
    pattern = '*.go',
    callback = function()
      require('go.format').goimports()
    end,
  })
EOF
