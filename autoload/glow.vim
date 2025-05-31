" glow.vim - Autoload functions
" Author: Maxim4711
" Version: 1.0

" Save cpoptions
let s:save_cpo = &cpoptions
set cpoptions&vim

let s:glow_preview_bufnr = -1
let s:glow_preview_winnr = -1
let s:glow_source_bufnr = -1

function! s:check_glow_available() abort
    return executable(g:glow_binary_path)
endfunction

function! s:get_glow_command() abort
    let l:cmd = g:glow_binary_path
    let l:cmd .= ' --style ' . shellescape(g:glow_style)
    let l:cmd .= ' --width ' . g:glow_width
    if g:glow_use_colors
        let l:cmd = 'FORCE_COLOR=1 ' . l:cmd
    endif
    return l:cmd
endfunction

function! s:create_preview_window() abort
    let l:current_winnr = win_getid()
    if s:glow_preview_winnr != -1 && win_id2win(s:glow_preview_winnr) != 0
        call win_gotoid(s:glow_preview_winnr)
    else
        execute 'vertical new'
        let s:glow_preview_winnr = win_getid()
        setlocal buftype=nofile bufhidden=wipe noswapfile
        setlocal readonly nomodifiable nonumber norelativenumber wrap
        setlocal filetype= syntax=
        silent! file [Glow\ Preview]
        let s:glow_preview_bufnr = bufnr('%')
    endif
    call win_gotoid(l:current_winnr)
    return 1
endfunction

function! s:render_ansi_colors() abort
    if !has('termguicolors') || !&termguicolors
        return
    endif
    
    call clearmatches()
    
    highlight GlowHeader guifg=#ff6b6b gui=bold
    highlight GlowBold guifg=#51cf66 gui=bold
    highlight GlowItalic guifg=#74c0fc gui=italic
    highlight GlowCode guifg=#ffd43b
    highlight GlowUnderline guifg=#9775fa gui=underline
    
    let l:total_lines = line('$')
    let l:line_num = 1
    while l:line_num <= l:total_lines
        let l:line = getline(l:line_num)
        
        let l:pos = 0
        while l:pos < len(l:line)
            let l:seq_start = match(l:line, '\e\[[0-9;]*m', l:pos)
            if l:seq_start == -1
                break
            endif
            
            let l:seq = matchstr(l:line, '\e\[[0-9;]*m', l:pos)
            let l:seq_end = l:seq_start + len(l:seq)
            
            let l:next_seq = match(l:line, '\e\[[0-9;]*m', l:seq_end)
            let l:text_end = l:next_seq == -1 ? len(l:line) : l:next_seq
            
            let l:before_text = substitute(strpart(l:line, 0, l:seq_start), '\e\[[0-9;]*m', '', 'g')
            let l:affected_text = substitute(strpart(l:line, l:seq_end, l:text_end - l:seq_end), '\e\[[0-9;]*m', '', 'g')
            
            let l:start_col = len(l:before_text) + 1
            let l:end_col = l:start_col + len(l:affected_text)
            
            if len(l:affected_text) > 0
                if match(l:seq, ';;1m') != -1
                    call matchadd('GlowHeader', '\%' . l:line_num . 'l\%>' . (l:start_col - 1) . 'c\%<' . l:end_col . 'c')
                elseif match(l:seq, ';1m') != -1
                    call matchadd('GlowBold', '\%' . l:line_num . 'l\%>' . (l:start_col - 1) . 'c\%<' . l:end_col . 'c')
                elseif match(l:seq, ';3m') != -1
                    call matchadd('GlowItalic', '\%' . l:line_num . 'l\%>' . (l:start_col - 1) . 'c\%<' . l:end_col . 'c')
                elseif match(l:seq, ';4m') != -1
                    call matchadd('GlowUnderline', '\%' . l:line_num . 'l\%>' . (l:start_col - 1) . 'c\%<' . l:end_col . 'c')
                elseif match(l:seq, ';m') != -1
                    call matchadd('GlowCode', '\%' . l:line_num . 'l\%>' . (l:start_col - 1) . 'c\%<' . l:end_col . 'c')
                endif
            endif
            
            let l:pos = l:text_end
        endwhile
        
        let l:line_num += 1
    endwhile
    
    setlocal modifiable
    let l:line_num = 1
    while l:line_num <= l:total_lines
        let l:line = getline(l:line_num)
        let l:clean_line = substitute(l:line, '\e\[[0-9;]*m', '', 'g')
        call setline(l:line_num, l:clean_line)
        let l:line_num += 1
    endwhile
    setlocal nomodifiable
endfunction

function! s:update_preview() abort
    if !s:check_glow_available() || &filetype !=# 'markdown'
        return 0
    endif
    
    let l:source_bufnr = bufnr('%')
    if l:source_bufnr == s:glow_preview_bufnr
        if s:glow_source_bufnr != -1 && bufexists(s:glow_source_bufnr)
            let l:source_bufnr = s:glow_source_bufnr
        else
            return 0
        endif
    endif
    
    let l:content = join(getbufline(l:source_bufnr, 1, '$'), "\n")
    
    let l:temp_file = tempname() . '.md'
    call writefile(split(l:content, "\n"), l:temp_file)
    let l:glow_cmd = s:get_glow_command() . ' ' . shellescape(l:temp_file)
    let l:glow_output = system(l:glow_cmd)
    call delete(l:temp_file)
    
    if s:glow_preview_winnr != -1 && win_id2win(s:glow_preview_winnr) != 0
        let l:current_winnr = win_getid()
        call win_gotoid(s:glow_preview_winnr)
        setlocal noreadonly modifiable
        %delete _
        call setline(1, split(l:glow_output, "\n"))
        
        if g:glow_render_colors
            call s:render_ansi_colors()
        endif
        
        setlocal readonly nomodifiable
        call win_gotoid(l:current_winnr)
    endif
    return 1
endfunction

function! s:sync_scroll() abort
    if !g:glow_sync_scroll || s:glow_preview_winnr == -1 || win_id2win(s:glow_preview_winnr) == 0
        return
    endif
    let l:current_winnr = win_getid()
    let l:source_line = line('.')
    let l:source_total = line('$')
    let l:relative_pos = l:source_total > 1 ? (l:source_line - 1.0) / (l:source_total - 1.0) : 0.0
    call win_gotoid(s:glow_preview_winnr)
    let l:preview_total = line('$')
    let l:target_line = float2nr(l:relative_pos * max([l:preview_total - 1, 0])) + 1
    let l:target_line = max([1, min([l:target_line, l:preview_total])])
    call cursor(l:target_line, 1)
    normal! zz
    call win_gotoid(l:current_winnr)
endfunction

function! glow#open() abort
    if !s:check_glow_available() || &filetype !=# 'markdown'
        return 0
    endif
    let s:glow_source_bufnr = bufnr('%')
    call s:create_preview_window()
    call s:update_preview()
    return 1
endfunction

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

function! glow#toggle() abort
    if s:glow_preview_winnr != -1 && win_id2win(s:glow_preview_winnr) != 0
        return glow#close()
    else
        return glow#open()
    endif
endfunction

function! glow#toggle_sync() abort
    let g:glow_sync_scroll = !g:glow_sync_scroll
    echo 'Scroll sync: ' . (g:glow_sync_scroll ? 'enabled' : 'disabled')
    return g:glow_sync_scroll
endfunction

function! glow#setup_buffer() abort
    augroup GlowBuffer
        autocmd! * <buffer>
        autocmd TextChanged,TextChangedI <buffer> call s:update_preview()
        autocmd CursorMoved <buffer> call s:sync_scroll()
    augroup END
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
