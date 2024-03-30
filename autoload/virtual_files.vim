if exists("g:loaded_virtual_files_vim_autoload")
  finish
endif
let g:loaded_virtual_files_vim_autoload = 1

" TODO make it so that writer is optional, and buffers loaded without an
"      associated writer are set to be unmodifiable
" TODO handle errors during write better (currently it still sets to
"      unmodified, and then won't rewrite when unmodified

function virtual_files#readCmd(handler)
  let l:filename = expand('<amatch>')
  let Reader = function(a:handler)
  let l:lines = Reader(l:filename)
  let l:tmpfile = tempname()
  call writefile(l:lines, l:tmpfile)
  exec "read " . l:tmpfile
  0d
endfunction

function virtual_files#writeCmd(handler)
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
"                    lines from the buffer, and can do whatever you want
function virtual_files#addHandler(pattern, reader, writer)
  augroup virtualfiles
    exec 'autocmd BufReadCmd ' . a:pattern . " call virtual_files#readCmd('" . a:reader . "')"
    exec 'autocmd BufWriteCmd ' . a:pattern . " call virtual_files#writeCmd('" . a:writer . "')"
  augroup END
endfunction

" add a bunch of new handlers all at once
" a:file_handlers should look like this:
"
" {'/some/directory/*.md': {'reader': 'ReadFunctionName', 'writer': 'WriteFunctionName'}}
function virtual_files#addHandlers(file_handlers)
  for pattern in keys(a:file_handlers)
    let l:handlers = a:file_handlers[pattern]
    call virtual_files#addHandler(pattern, l:handlers['reader'], l:handlers['writer'])
  endfor
endfunction

function virtual_files#clearHandlers()
  augroup virtualfiles
    autocmd!
  augroup END
endfunction
