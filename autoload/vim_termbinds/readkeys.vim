
let s:buf = []

function! s:ReadIfNecessary()
  if empty(s:buf)
    call add(s:buf, nr2char(getchar()))
  endif
endfunction

function! s:PeekChar()
  call s:ReadIfNecessary()
  return s:buf[0]
endfunction

function! s:PopChar()
  let l:retval = s:PeekChar()
  let s:buf = s:buf[1:]
  return l:retval
endfunction

function! s:ClearBuf()
  let s:buf = []
endfunction

function! s:ReadCount()
  let l:count = ''
  while s:PeekChar() =~# '\d'
    let l:count .= s:PopChar()
  endwhile
  return l:count
endfunction

function! vim_termbinds#readkeys#ReadKeys()
  call s:ClearBuf()

  let l:count = s:ReadCount()

  let l:cmd = s:PopChar()
  if l:cmd ==# '"' " putting a register
    let l:register = s:PopChar()
    if l:register == '='
      let l:expr = input('=')
      let l:cmd = ':put =' . l:expr . "\<cr>"
      return l:cmd
    endif
    let l:cmd .= l:register
    let l:cmd .= 'p'
    return l:cmd
  elseif l:cmd == ':' " entering cmdline mode
    let l:initial_text = ''
    if !empty(l:count)
      let l:initial_text = '.,.+' . (l:count - 1)
    endif
    let l:excmd = input(':', l:initial_text, 'command')
    let l:cmd .= l:excmd . "\<cr>"
    return l:cmd
  elseif l:cmd == 'g' " switching tabs
    let l:direction = s:PeekChar()
    if l:direction ==? 't'
      let l:cmd .= s:PopChar()
      let l:cmd = "\<C-w>" . l:count . l:cmd
      return l:cmd
    endif
  endif

  let l:cmd = "\<C-w>" . l:count . l:cmd
  return l:cmd
endfunction
