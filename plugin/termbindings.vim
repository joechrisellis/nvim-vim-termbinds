
if !has("nvim") || exists("g:loaded_vim_termbinds")
    finish
endif
let g:loaded_vim_termbinds = 1

let s:NORMAL_MODE = 'n'
let s:TERMINAL_MODE = 't'

function! s:SetNormalMode()
  let b:term_mode = s:NORMAL_MODE
endfunction

function! s:SetTerminalMode()
  let b:term_mode = s:TERMINAL_MODE
endfunction

function! s:EnterTerminalMode()
  call nvim_feedkeys('i', 'inx', v:false)
endfunction

" When the user enters normal mode by request, in order to match Vim's
" behaviour, we have to set a flag to say that the buffer is now in normal
" mode.
tnoremap <silent> <C-\><C-n> <C-\><C-n>:<C-u>call <sid>SetNormalMode()<cr>
tmap <silent> <C-w>N <C-\><C-n>

function! s:TermEnter()
  if &buftype !=# 'terminal'
    return
  endif

  let l:term_mode = get(b:, 'term_mode', s:TERMINAL_MODE)
  if l:term_mode ==# s:TERMINAL_MODE
    call s:EnterTerminalMode()
  endif
endfunction

augroup vim_termbindings
  autocmd!
  " We should run TermEnter() when:
  " - the user switches buffer (they might switch to a terminal buffer)
  " - the user switches window (they might switch to a terminal window)
  " - mouse is released (they might have just clicked on a terminal window)
  autocmd BufEnter * call s:TermEnter()
  autocmd WinEnter * call s:TermEnter()
  autocmd TermOpen * nnoremap <silent><buffer><leftrelease> <leftrelease>:<C-u>call <sid>TermEnter()<cr>
augroup END

function! s:CtrlWHandler()
  call s:SetTerminalMode()
  try
    let l:key_cmd = vim_termbinds#readkeys#ReadKeys()
  catch /^Vim:Interrupt$/
    call s:EnterTerminalMode()
    return
  endtry


  let l:winnr_before = win_getid()
  call nvim_feedkeys("\<C-\>\<C-n>" . l:key_cmd, 'intx', v:false)
  let l:winnr_after = win_getid()

  if l:winnr_before == l:winnr_after
    call s:EnterTerminalMode()
  endif
endfunction

" Handler for CTRL-W bindings (anything that's not Vim-terminal-mode-specific
" will be treated as a window command).
tnoremap <silent> <C-w> <C-\><C-n>:<C-u>call <sid>CtrlWHandler()<cr>

" ... and the easier things.
tnoremap <silent> <C-w>. <C-w>
tnoremap <silent> <C-w><C-\> <C-\>
tnoremap <silent> <cmd> <C-w><C-c> <cmd>call jobstop(b:terminal_job_id)<cr>
