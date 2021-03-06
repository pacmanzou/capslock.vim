" capslock.vim - Software caps lock

if exists("g:loaded_capslock") || v:version < 700 || &cp
    finish
endif
let g:loaded_capslock = 1

let s:cpo_save = &cpo
set cpo&vim

" Code {{{1

function! s:enable(mode, ...) abort
    if a:mode == 'i'
        let b:capslock = 1 + a:0
    endif
    if a:mode == 'c' || !exists('##InsertCharPre')
        let i = char2nr('A')
        while i <= char2nr('Z')
            exe a:mode."noremap <buffer>" nr2char(i) nr2char(i+32)
            exe a:mode."noremap <buffer>" nr2char(i+32) nr2char(i)
            let i = i + 1
        endwhile
    endif
    let &l:readonly = &l:readonly
    return ''
endfunction

function! s:disable(mode) abort
    if a:mode == 'i'
        unlet! b:capslock
    endif
    if a:mode == 'c' || !exists('##InsertCharPre')
        let i = char2nr('A')
        while i <= char2nr('Z')
            silent! exe a:mode."unmap <buffer>" nr2char(i)
            silent! exe a:mode."unmap <buffer>" nr2char(i+32)
            let i = i + 1
        endwhile
    endif
    let &l:readonly = &l:readonly
    return ''
endfunction

function! s:toggle(mode, ...) abort
    if s:enabled(a:mode)
        return s:disable(a:mode)
    elseif a:0
        return s:enable(a:mode,a:1)
    else
        return s:enable(a:mode)
    endif
endfunction

function! s:enabled(mode) abort
    if a:mode == 'i' && exists('##InsertCharPre')
        return get(b:, 'capslock', 0)
    else
        return maparg('a',a:mode) == 'A'
    endif
endfunction

function! s:exitcallback() abort
    if s:enabled('i') == 1
        call s:disable('i')
    endif
endfunction

function! CapsLockStatusline(...) abort
    return s:enabled('i') ? (a:0 == 1 ? a:1 : 'CAPS ') : ''
endfunction

augroup capslock
    autocmd!
    autocmd User Flags call Hoist('window', 'CapsLockStatusline')

    autocmd InsertLeave * call s:exitcallback()
    if exists('##InsertCharPre')
        autocmd InsertCharPre *
                    \ if s:enabled('i') |
                    \   let v:char = v:char ==# tolower(v:char) ? toupper(v:char) : tolower(v:char) |
                    \ endif
    endif
augroup END

" }}}1
" Maps {{{1

nnoremap <silent> <Plug>CapsLockToggle  :<C-U>call <SID>toggle('i',1)<CR>
nnoremap <silent> <Plug>CapsLockEnable  :<C-U>call <SID>enable('i',1)<CR>
nnoremap <silent> <Plug>CapsLockDisable :<C-U>call <SID>disable('i')<CR>
inoremap <silent> <Plug>CapsLockToggle  <C-R>=<SID>toggle('i')<CR>
inoremap <silent> <Plug>CapsLockEnable  <C-R>=<SID>enable('i')<CR>
inoremap <silent> <Plug>CapsLockDisable <C-R>=<SID>disable('i')<CR>
cnoremap <silent> <Plug>CapsLockToggle  <C-R>=<SID>toggle('c')<CR>
cnoremap <silent> <Plug>CapsLockEnable  <C-R>=<SID>enable('c')<CR>
cnoremap <silent> <Plug>CapsLockDisable <C-R>=<SID>disable('c')<CR>

" if empty(mapcheck("<C-L>", "i"))
"   imap <C-L> <Plug>CapsLockToggle
" endif
imap <C-G>c <Plug>CapsLockToggle
nmap <C-G>c <Plug>CapsLockToggle

" }}}1

let &cpo = s:cpo_save
