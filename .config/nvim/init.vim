"################################################
"##
"#### Vim config
"##
"################################################
scriptencoding=utf-8
:set autoindent
:set background=dark
:set encoding=utf-8
:set mouse=a
:set number
:set shiftwidth=4
:set smarttab
:set softtabstop=4
:set tabstop=4
":set termguicolors



"################################################
"##
"#### Keybindings
"##
"################################################
nnoremap <C-q> :q!<CR>
nnoremap <C-c> :sp<bar>term<cr><c-w>J:resize10<cr>i
nnoremap <C-s> :w<CR>
nnoremap <C-n> :NvimTreeToggle<CR>
nnoremap <C-p> :PlugInstall<CR>



"################################################
"##
"#### Macros
"##
"################################################
"#~~~ move cursor 
autocmd BufReadPost * if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif 



"################################################
"##
"#### Vim plugin manager
"##
"################################################
call plug#begin()


"#~~~ tab manager
Plug 'akinsho/bufferline.nvim'

"#~~~ discord rpc
Plug 'andweeb/presence.nvim'

"#~~~ completion menu
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

"#~~~ icons
Plug 'nvim-tree/nvim-web-devicons'


call plug#end()



"################################################
"##
"#### Load plugins
"##
"################################################
"#~~~ bufferline
":luafile ~/.config/nvim/config.d/bufferline.lua
lua require'bufferline'.setup{}
