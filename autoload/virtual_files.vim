if exists("g:loaded_virtual_files_vim_autoload")
  finish
endif
let g:loaded_virtual_files_vim_autoload = 1

" TODO handle errors during write better (currently it still sets to
"      unmodified, and then won't rewrite when unmodified

function! s:getAbsolutePath()
  return fnamemodify(expand('<amatch>'), ':p')
endfunction

function! virtual_files#readCmd(handler, isModifiable)
  let l:filename = expand('<amatch>')
  let Reader = function(a:handler)
  let l:lines = Reader(l:filename)
  let l:tmpfile = tempname()
  call writefile(l:lines, l:tmpfile)
  exec "read " . l:tmpfile
  0d
  if a:isModifiable
    setlocal buftype=acwrite
  else
    setlocal buftype=nofile
    setlocal nomodifiable
  endif
endfunction

function! virtual_files#writeCmd(handler)
  let l:filename = expand('<amatch>')
  if getbufvar('%', '&modified')
    let Writer = function(a:handler)
    call Writer(l:filename, getline(0, '$'))
    set nomodified
  endif
endfunction

" add a new set of handlers at runtime
" 
" a:pattern  String  the glob pattern used to define when these handlers are
"                    used
" a:reader   String  the name of the function used to load the file. The
"                    function should take a string filepath, and return a list
"                    of lines to use as the buffer
" a:writer   String  the name of the function used to write the file. The
"                    function should take a string filepath and a list of
"                    lines from the buffer, and can do whatever you want. If
"                    you don't need a writer, use an empty string
function! virtual_files#addHandler(pattern, reader, writer)
  let l:isModifiable = (a:writer != '')
  augroup virtualfiles
    exec 'autocmd BufReadCmd ' . a:pattern . " call virtual_files#readCmd('" . a:reader . "', " . l:isModifiable .")"
    if l:isModifiable
      exec 'autocmd BufWriteCmd ' . a:pattern . " call virtual_files#writeCmd('" . a:writer . "')"
    endif
  augroup END
endfunction

" add a bunch of new handlers all at once
" a:file_handlers should look like this:
"
" {'/some/directory/*.md': {'reader': 'ReadFunctionName', 'writer': 'WriteFunctionName'}}
"
" For each pattern, 'reader' is mandatory, 'writer' is optional
function! virtual_files#addHandlers(file_handlers)
  for pattern in keys(a:file_handlers)
    let l:handlers = a:file_handlers[pattern]
    let l:reader = l:handlers['reader']
    let l:writer = has_key(l:handlers, 'writer') ? l:handlers['writer'] : ''
    call virtual_files#addHandler(pattern, l:reader, l:writer)
  endfor
endfunction

function! virtual_files#clearHandlers()
  augroup virtualfiles
    autocmd!
  augroup END
endfunction
