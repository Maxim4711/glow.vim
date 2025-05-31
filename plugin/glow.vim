i" glow.vim - Markdown preview with glow in vertical split
" Author: Maxim4711
" Version: 1.0
" License: MIT
"
" This plugin is a Vimscript reimplementation of the original idea from
" glow.nvim (https://github.com/ellisonleao/glow.nvim)

if exists('g:loaded_glow') || v:version < 800
    finish
endif
let g:loaded_glow = 1

" Save cpoptions
let s:save_cpo = &cpoptions
set cpoptions&vim

" Configuration variables with defaults
if !exists('g:glow_binary_path')
    let g:glow_binary_path = 'glow'
endif

if !exists('g:glow_width')
    let g:glow_width = 80
endif

if !exists('g:glow_style')
    let g:glow_style = 'auto'
endif

if !exists('g:glow_pager')
    let g:glow_pager = 0
endif

if !exists('g:glow_sync_scroll')
    let g:glow_sync_scroll = 1
endif

" Commands
command! GlowToggle call glow#toggle()
command! GlowOpen call glow#open()
command! GlowClose call glow#close()
command! GlowToggleSync call glow#toggle_sync()

" Default key mappings
if !exists('g:glow_disable_default_mappings') || !g:glow_disable_default_mappings
    nnoremap <silent> <Leader>p :GlowToggle<CR>
    nnoremap <silent> <Leader>P :GlowToggleSync<CR>
endif

" Set up autocommands
augroup GlowPlugin
    autocmd!
    " Only activate for markdown files
    autocmd FileType markdown call glow#setup_buffer()
augroup END

" Restore cpoptions
let &cpoptions = s:save_cpo
unlet s:save_cpo
