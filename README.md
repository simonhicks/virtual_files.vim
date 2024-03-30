# `virtual_files.vim`

This is a utility plugin that makes it easy to set up buffer read/write commands in vim. You can use
it to create virtual filetypes or virtual folders that are read and saved using your custom code.

## Usage
This plugin provides three new functions

### `virtual_files#addHandler(pattern, reader, writer)`

This sets up a pair of autocomands for reading and writing virtual files.

    a:pattern  String  the glob pattern used to define when these handlers are
                      used
    a:reader   String  the name of the function used to load the file. The
                      function should take a string filepath, and return a list
                      of lines to use as the buffer
    a:writer   String  the name of the function used to write the file. The
                      function should take a string filepath and a list of
                      lines from the buffer, and can do whatever you want. If
                      you don't need a writer function, use ''

Here's an example of how to use it.

```{.vimscript}
" TestReader reads the file as normal, and drops the first and last line before loading it into a
" vim buffer
function TestReader(filename)
  let l:lines = []
  if (filereadable(a:filename))
    let l:lines = readfile(a:filename)[1:-2]
  endif
  return l:lines
endfunction

" TestWriter adds a marker line to the start and end of the buffer before writing it to a file as
" normal
function TestWriter(filename, lines)
  let l:transformedLines = ["---test start---"] + a:lines + ["---test end---"]
  call writefile(l:transformedLines, a:filename)
endfunction

" adds handlers for all markdown files in the /home/simon/test directory. This makes vim use
" TestReader to load these files, and TestWriter to save them. In effect, markdown files in this
" directory will be saved on disk with the extra marker lines but those lines won't be visible in
" vim.
call virtual_files#addHandler('/home/simon/test/*.md', 'TestWriter', 'TestReader')
```

### `virtual_files#addHandlers(file_handlers)`

This is a thin wrapper around `virtual_files#addHandler` which takes a map of handlers, and sets them all
up at once. For the example above, you can use it like this:

```{.vimscript}
let l:virtual_file_handlers = {
      \   '/home/simon/test/*.md': {
      \     'writer': 'TestWriter',
      \     'reader': 'TestReader'
      \   }
      \ }

call virtual_files#addHandlers(l:virtual_file_handlers)
```

### `virtual_files#clearHandlers()`

This just clears all the handlers you've previously set.


## Contributing

There's a test configuration in `test/virtual_files.vim`, along with a script for how to test all
the functionality this supports in the comments. If you want to make a PR, just make sure you update
the tests and this README
