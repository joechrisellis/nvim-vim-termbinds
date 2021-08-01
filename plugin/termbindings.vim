
if !has("nvim")
  finish
endif

function! EnterNormalMode()
  call nvim_feedkeys("\<C-\><C-n>", 'inx', v:false)
  let b:term_mode = mode()
endfunction

function! EnterInsertMode()
  call nvim_feedkeys('i', 'inx', v:false)
  let b:term_mode = mode()
endfunction

" When the user enters normal mode by request, in order to match Vim's
" behaviour, we have to set a flag to say that the buffer is now in normal
" mode.
tnoremap <silent> <C-\><C-n> <C-\><C-n>:<C-u>call EnterNormalMode()<cr>
tmap <silent> <C-w>N <C-\><C-n>

function! TermEnter()
  if &buftype !=# 'terminal'
    return
  endif

  let l:term_mode = get(b:, 'term_mode', 't')
  if l:term_mode ==# 't'
    call EnterInsertMode()
  endif
endfunction

augroup vim_termbindings
  autocmd!
  " We should try to run TermEnter() when:
  " - the user switches buffer (they might switch to a terminal buffer)
  " - the user switches window (they might switch to a terminal window)
  " - mouse is released (they might have just clicked on a terminal window)
  autocmd BufEnter * call TermEnter()
  autocmd WinEnter * call TermEnter()
  autocmd TermOpen * nnoremap <buffer><leftrelease> <leftrelease>:<C-u>call TermEnter()<cr>
augroup END

function! CtrlWHandler()
  try
    let l:key_cmd = ReadKeys()
  catch /^Vim:Interrupt$/
    call EnterInsertMode()
    return
  endtry

  let b:term_mode = 't'

  let l:winnr_before = win_getid()
  call nvim_feedkeys("\<C-\>\<C-n>" . l:key_cmd, 'intx', v:false)
  let l:winnr_after = win_getid()

  if l:winnr_before == l:winnr_after
    call EnterInsertMode()
  endif
endfunction

" Handler for CTRL-W bindings (anything that's not Vim-terminal-mode-specific
" will be treated as a window command).
tnoremap <silent> <C-w> <C-\><C-n>:<C-u>call CtrlWHandler()<cr>

" ... and the easier things.
tnoremap <silent> <C-w>. <C-w>
tnoremap <silent> <C-w><C-\> <C-\>
tnoremap <silent> <cmd> <C-w><C-c> <cmd>call jobstop(b:terminal_job_id)<cr>
