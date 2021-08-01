
let s:buf = []

function! ReadIfNecessary()
  if empty(s:buf)
    call add(s:buf, nr2char(getchar()))
  endif
endfunction

function! PeekChar()
  call ReadIfNecessary()
  return s:buf[0]
endfunction

function! PopChar()
  let l:retval = PeekChar()
  let s:buf = s:buf[1:]
  return l:retval
endfunction

function! ClearBuf()
  let s:buf = []
endfunction

function! ReadCount()
  let l:count = ''
  while PeekChar() =~# '\d'
    let l:count .= PopChar()
  endwhile
  return l:count
endfunction

function! ReadKeys()
  call ClearBuf()

  let l:count = ReadCount()

  let l:cmd = PopChar()
  if l:cmd ==# '"' " putting a register
    let l:register = PopChar()
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
    let l:direction = PeekChar()
    if l:direction ==? 't'
      let l:cmd .= PopChar()
      let l:cmd = "\<C-w>" . l:count . l:cmd
      return l:cmd
    endif
  endif

  let l:cmd = "\<C-w>" . l:count . l:cmd
  return l:cmd
endfunction
