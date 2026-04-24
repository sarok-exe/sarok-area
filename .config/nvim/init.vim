" ═══════════════════════════════════════════════════════════════════
" Neovim Config - Sarok's Setup
" ═══════════════════════════════════════════════════════════════════

" Initialize vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Plugins
call plug#begin('~/.config/nvim/plugged')

" --- Essential ---
Plug 'tpope/vim-sensible'                    " Sensible defaults
Plug 'preservim/nerdtree'                    " File explorer
Plug 'vim-airline/vim-airline'               " Status bar
Plug 'vim-airline/vim-airline-themes'        " Airline themes

" --- Navigation ---
Plug 'scrooloose/nerdtree'                   " NERDTree
Plug 'Xuyuanp/nerdtree-git-status'          " Git status in NERDTree
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'                      " Fuzzy finder
Plug 'christoomey/vim-tmux-navigator'       " Tmux navigation

" --- Git ---
Plug 'airblade/vim-gitgutter'                " Git diff in gutter
Plug 'tpope/vim-fugitive'                    " Git commands
Plug 'rhysd/committia.vim'                   " Better git commits

" --- Editing ---
Plug 'jiangmiao/auto-pairs'                   " Auto pairs
Plug 'tpope/vim-surround'                    " Surround
Plug 'tpope/vim-commentary'                  " Comment lines
Plug 'vim-scripts/ReplaceWithRegister'       " Replace with register
Plug 'machakann/vim-sandwich'                " Sandwich text objects

" --- LSP & Completion ---
Plug 'neoclide/coc.nvim', {'branch': 'release'}  " LSP client
Plug 'honza/vim-snippets'                    " Snippets

" --- UI Enhancement ---
Plug 'morhetz/gruvbox'                       " Gruvbox theme
Plug 'arzg/vim-colors-xresources'           " Xresources colors
Plug 'flazz/vim-colorschemes'               " Color schemes collection
Plug 'ryanoasis/vim-devicons'               " DevIcons
Plug 'machakann/vim-highlightedyank'        " Highlight yank

" --- Tools ---
Plug 'mbbill/undotree'                       " Undo tree
Plug 'tpope/vim-unimpaired'                 " Unimpaired shortcuts
Plug 'easymotion/vim-easymotion'             " EasyMotion
Plug 'tpope/vim-repeat'                      " Repeat with .
Plug 'AndrewRadev/sideways.vim'              " Move arguments
Plug 'AndrewRadev/splitjoin.vim'            " Split/join lines

" --- Python ---
Plug 'davidhalter/jedi-vim'                  " Python completion
Plug 'python-mode/python-mode', { 'for': 'python', 'do': 'Set Pythonp' }
Plug 'numirias/semshi', { 'do': ':UpdateRemotePlugins' }  " Python syntax

call plug#end()

" ═══════════════════════════════════════════════════════════════════
" General Settings
" ═══════════════════════════════════════════════════════════════════

set nocompatible
filetype plugin indent on
syntax enable

" Encoding
set encoding=utf-8
set fileencoding=utf-8

" Files
set hidden
set autoread
set noswapfile
set nobackup
set undofile
set undodir=~/.config/nvim/undo
set backupdir=~/.config/nvim/backup
set directory=~/.config/nvim/swap

" UI
set number
set relativenumber
set cursorline
set termguicolors
set scrolloff=8
set sidescrolloff=8
set showmode
set showcmd
set showmatch
set laststatus=2
set cmdheight=1
set shortmess+=c
set colorcolumn=120
set signcolumn=yes

" Theme (Gruvbox)
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_italic=1
colorscheme gruvbox
highlight CursorLineNr cterm=NONE ctermbg=NONE ctermfg=cyan gui=NONE guibg=NONE guifg=cyan

" ═══════════════════════════════════════════════════════════════════
" Key Mappings
" ═══════════════════════════════════════════════════════════════════

let mapleader = " "

" Save & Quit
nnoremap <leader>w :w<cr>
nnoremap <leader>q :q<cr>
nnoremap <leader>Q :qa!<cr>
nnoremap <leader>x :bd<cr>

" Window navigation
nnoremap <leader>h :wincmd h<cr>
nnoremap <leader>l :wincmd l<cr>
nnoremap <leader>j :wincmd j<cr>
nnoremap <leader>k :wincmd k<cr>
nnoremap <leader>o :wincmd o<cr>

" Split
nnoremap <leader>sv :split<cr>
nnoremap <leader>sh :split<cr>:wincmd h<cr>
nnoremap <leader>sv :vsplit<cr>
nnoremap <leader>sx :vsplit<cr>:wincmd l<cr>

" NERDTree
nnoremap <leader>t :NERDTreeToggle<cr>
nnoremap <leader>nt :NERDTree<cr>
nnoremap <leader>nf :NERDTreeFocus<cr>

" FZF
nnoremap <leader>ff :Files<cr>
nnoremap <leader>fg :GFiles<cr>
nnoremap <leader>fb :Buffers<cr>
nnoremap <leader>fh :Helptags<cr>
nnoremap <leader>fm :Marks<cr>

" UndoTree
nnoremap <leader>u :UndotreeToggle<cr>

" Git
nnoremap <leader>gg :Git<cr>
nnoremap <leader>gs :Git status<cr>
nnoremap <leader>gc :Git commit<cr>
nnoremap <leader>gp :Git push<cr>
nnoremap <leader>gl :Git pull<cr>

" EasyMotion
map <leader>j <plug>(easymotion-j)
map <leader>k <plug>(easymotion-k)
map <leader>w <plug>(easymotion-w)
map <leader>b <plug>(easymotion-b)

" Highlight yank
nnoremap <leader>y :Highlightedyank<cr>

" Comment
nnoremap <leader>/ :Commentary<cr>
vnoremap <leader>/ :Commentary<cr>

" Terminal
nnoremap <leader>term :terminal<cr>
tnoremap <leader>term <c-\><c-n>:bdelete!<cr>

" LSP
nnoremap <leader>ld :call CocAction('showDefinition')<cr>
nnoremap <leader>lr :call CocAction('rename')<cr>
nnoremap <leader>lf :call CocAction('format')<cr>
nnoremap <leader>la :call CocAction('codeAction')<cr>
nnoremap <leader>ls :call CocAction('signatureHelp')<cr>
nnoremap <leader>le :call CocAction('doHover')<cr>

" ═══════════════════════════════════════════════════════════════════
" Plugin Settings
" ═══════════════════════════════════════════════════════════════════

" NERDTree
let NERDTreeShowHidden = 1
let NERDTreeIgnore = ['\.git$']
let NERDTreeMinimalUI = 1
let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ 'Modified'  : '✹',
    \ 'Staged'    : '✚',
    \ 'Untracked' : '✭',
    \ 'Renamed'   : '➜',
    \ 'Unmerged'  : '═',
    \ 'Deleted'   : '✖',
    \ 'Dirty'     : '✗',
    \ 'Ignored'   : '☒',
    \ 'Clean'     : '☑',
    \ 'Unknown'   : '?'
    \ }

" Airline
let g:airline#extensions#coc#enabled = 1
let g:airline#extensions#gitgutter#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme = 'gruvbox'

" EasyMotion
let g:EasyMotion_do_mapping = 0
let g:EasyMotion_enter_jump_first = 1

" GitGutter
let g:gitgutter_sign_added = '✚'
let g:gitgutter_sign_modified = '✹'
let g:gitgutter_sign_removed = '✖'
let g:gitgutter_sign_removed_first_line = '▲'
let g:gitgutter_sign_modified_removed = '✼'

" Jedi
let g:jedi#show_call_signatures = 1
let g:jedi#auto_vim_configuration = 1
let g:jedi#force_py_version = 3

" Coc
let g:coc_global_extensions = [
    \ 'coc-python',
    \ 'coc-json',
    \ 'coc-tsserver',
    \ 'coc-html',
    \ 'coc-css',
    \ 'coc-yank',
    \ 'coc-git',
    \ 'coc-lists',
    \ 'coc-snippets'
    \ ]

" FZF
let g:fzf_action = {
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-x': 'split',
    \ 'ctrl-v': 'vsplit'
    \ }

" Python-mode
let g:pymode = 1
let g:pymode_lint = 1
let g:pymode_trim_whitespace = 1
let g:pymode_utils_rope = 0
let g:pymode_rope = 0

" Highlightedyank
let g:highlightedyank_highlight_duration = 2000
let g:highlightedyank_highlight_timers = {'highlightedyank': {'time': 2000}}

" ═══════════════════════════════════════════════════════════════════
" Custom Functions
" ═══════════════════════════════════════════════════════════════════

" Auto-create directories
function! EnsureDirExists(dir)
    if !isdirectory(a:dir)
        call mkdir(a:dir, 'p')
    endif
endfunction

call EnsureDirExists($HOME . '/.config/nvim/undo')
call EnsureDirExists($HOME . '/.config/nvim/backup')
call EnsureDirExists($HOME . '/.config/nvim/swap')

" Auto-save on focus lost
au FocusLost * :wa

" Clear trailing whitespace
function! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfunction
nnoremap <leader>tw :call TrimWhitespace()<cr>

" Open init.vim
nnoremap <leader>ev :edit ~/.config/nvim/init.vim<cr>

" Reload init.vim
nnoremap <leader>rv :source ~/.config/nvim/init.vim<cr>

" Format JSON
command! FormatJSON %!python3 -m json.tool

" ═══════════════════════════════════════════════════════════════════
" Auto-commands
" ═══════════════════════════════════════════════════════════════════

" Save on focus lost
au FocusLost * :wa

" Strip trailing whitespace on save
autocmd BufWritePre * :call TrimWhitespace()

" Close NERDTree if only window
autocmd WinEnter * if winnr() == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" Start NERDTree if no files
autocmd VimEnter * if @% == '' && argc() == 0 | NERDTree | endif

" Open FZF with ctrl-p
nnoremap <c-p> :Files<cr>

" ═══════════════════════════════════════════════════════════════════
" Status Line
" ═══════════════════════════════════════════════════════════════════

set statusline=%{FugitiveStatusline()}
set statusline+=\ %f
set statusline+=\ %m%r%y
set statusline+=\ %=
set statusline+=\ %l:%c\ \|
set statusline+=\ %p%%\ \|

" ═══════════════════════════════════════════════════════════════════
" End of Config
" ═══════════════════════════════════════════════════════════════════