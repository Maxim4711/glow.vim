" glow.vim - Autoload functions
" Author: Maxim4711
" Version: 1.0

" Save cpoptions
let s:save_cpo = &cpoptions
set cpoptions&vim

" Global state variables
let s:glow_preview_bufnr = -1
let s:glow_preview_winnr = -1
let s:glow_source_bufnr = -1

" Check if glow binary is available
function! s:check_glow_available() abort
    if !executable(g:glow_binary_path)
        echohl ErrorMsg
        echomsg 'glow.vim: Glow binary not found at: ' . g:glow_binary_path
        echomsg 'glow.vim: Please install glow or set g:glow_binary_path'
        echohl None
        return 0
    endif
    return 1
endfunction

" Get glow command with configured options
function! s:get_glow_command() abort
    let l:cmd = g:glow_binary_path
    let l:cmd .= ' --style ' . shellescape(g:glow_style)
    let l:cmd .= ' --width ' . g:glow_width
    if g:glow_pager
        let l:cmd .= ' --pager'
    endif
    return l:cmd
endfunction

" Create or get preview window
function! s:create_preview_window() abort
    " Save current window
    let l:current_winnr = win_getid()
    
    " Check if preview window exists and is valid
    if s:glow_preview_winnr != -1 && win_id2win(s:glow_preview_winnr) != 0
        " Window exists, just go to it
        call win_gotoid(s:glow_preview_winnr)
    else
        " Create new vertical split
        execute 'vertical new'
        let s:glow_preview_winnr = win_getid()
        
        " Configure the preview buffer
        setlocal buftype=nofile
        setlocal bufhidden=wipe
        setlocal noswapfile
        setlocal readonly
        setlocal nomodifiable
        setlocal nonumber
        setlocal norelativenumber
        setlocal wrap
        setlocal filetype=
        setlocal syntax=
        
        " Set a recognizable buffer name
        silent! file [Glow\ Preview]
        
        let s:glow_preview_bufnr = bufnr('%')
    endif
    
    " Return to original window
    call win_gotoid(l:current_winnr)
    return 1
endfunction

" Update preview content with current buffer
function! s:update_preview() abort
    if !s:check_glow_available()
        return 0
    endif
    
    " Only process markdown files
    if &filetype !=# 'markdown'
        return 0
    endif
    
    " Get current buffer content
    let l:content = join(getline(1, '$'), "\n")
    if empty(l:content)
        return 0
    endif
    
    " Create temporary file
    let l:temp_file = tempname() . '.md'
    try
        call writefile(split(l:content, "\n"), l:temp_file)
        
        " Generate glow output
        let l:glow_cmd = s:get_glow_command() . ' ' . shellescape(l:temp_file)
        let l:glow_output = system(l:glow_cmd)
        
        " Check for command errors
        if v:shell_error != 0
            echohl ErrorMsg
            echomsg 'glow.vim: Error running glow command'
            echomsg 'glow.vim: ' . l:glow_output
            echohl None
            return 0
        endif
        
    finally
        " Clean up temp file
        if filereadable(l:temp_file)
            call delete(l:temp_file)
        endif
    endtry
    
    " Update preview window if it exists
    if s:glow_preview_winnr != -1 && win_id2win(s:glow_preview_winnr) != 0
        let l:current_winnr = win_getid()
        call win_gotoid(s:glow_preview_winnr)
        
        " Update content
        setlocal noreadonly modifiable
        silent %delete _
        
        if !empty(l:glow_output)
            call setline(1, split(l:glow_output, "\n"))
        else
            call setline(1, ['[Empty or invalid markdown content]'])
        endif
        
        setlocal readonly nomodifiable
        
        " Return to source window
        call win_gotoid(l:current_winnr)
    endif
    
    return 1
endfunction

" Synchronize scrolling between source and preview
function! s:sync_scroll() abort
    if !g:glow_sync_scroll || s:glow_preview_winnr == -1 || win_id2win(s:glow_preview_winnr) == 0
        return
    endif
    
    let l:current_winnr = win_getid()
    let l:source_line = line('.')
    let l:source_total = line('$')
    
    " Calculate relative position (0.0 to 1.0)
    let l:relative_pos = l:source_total > 1 ? (l:source_line - 1.0) / (l:source_total - 1.0) : 0.0
    
    " Switch to preview window
    call win_gotoid(s:glow_preview_winnr)
    let l:preview_total = line('$')
    
    " Calculate target line in preview
    let l:target_line = float2nr(l:relative_pos * max([l:preview_total - 1, 0])) + 1
    let l:target_line = max([1, min([l:target_line, l:preview_total])])
    
    " Set cursor position and center view
    call cursor(l:target_line, 1)
    normal! zz
    
    " Return to source window
    call win_gotoid(l:current_winnr)
endfunction

" Public API functions

" Toggle preview window
function! glow#toggle() abort
    if s:glow_preview_winnr != -1 && win_id2win(s:glow_preview_winnr) != 0
        " Preview is open, close it
        return glow#close()
    else
        " Preview is closed, open it
        return glow#open()
    endif
endfunction

" Open preview window
function! glow#open() abort
    if !s:check_glow_available()
        return 0
    endif
    
    if &filetype !=# 'markdown'
        echohl WarningMsg
        echomsg 'glow.vim: Not a markdown file'
        echohl None
        return 0
    endif
    
    if s:glow_preview_winnr != -1 && win_id2win(s:glow_preview_winnr) != 0
        " Already open
        return 1
    endif
    
    if !s:create_preview_window()
        return 0
    endif
    
    if !s:update_preview()
        call glow#close()
        return 0
    endif
    
    let s:glow_source_bufnr = bufnr('%')
    return 1
endfunction

" Close preview window  
function! glow#close() abort
    if s:glow_preview_winnr != -1 && win_id2win(s:glow_preview_winnr) != 0
        let l:current_winnr = win_getid()
        call win_gotoid(s:glow_preview_winnr)
        close
        call win_gotoid(l:current_winnr)
    endif
    
    let s:glow_preview_winnr = -1
    let s:glow_preview_bufnr = -1
    return 1
endfunction

" Toggle scroll synchronization
function! glow#toggle_sync() abort
    let g:glow_sync_scroll = !g:glow_sync_scroll
    echomsg 'glow.vim: Scroll sync ' . (g:glow_sync_scroll ? 'enabled' : 'disabled')
    return g:glow_sync_scroll
endfunction

" Check if preview window is open
function! glow#is_open() abort
    return s:glow_preview_winnr != -1 && win_id2win(s:glow_preview_winnr) != 0
endfunction

" Manually update preview
function! glow#update() abort
    return s:update_preview()
endfunction

" Set up buffer-specific autocommands
function! glow#setup_buffer() abort
    augroup GlowBuffer
        autocmd! * <buffer>
        " Update preview on content changes
        autocmd TextChanged,TextChangedI <buffer> call s:update_preview()
        autocmd BufWritePost <buffer> call s:update_preview()
        
        " Sync scrolling on cursor movement
        autocmd CursorMoved <buffer> call s:sync_scroll()
        
        " Clean up when leaving buffer
        autocmd BufWinLeave <buffer> call glow#close()
    augroup END
endfunction

" Restore cpoptions
let &cpoptions = s:save_cpo
unlet s:save_cpo
