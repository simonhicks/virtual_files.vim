" This is a test configuration that uses every feature of the plugin. To test
" the plugin, try the following:
"
" Setup: vim -c 'so test/virtual_files.vim'
"
" 1. open `yesterday.time`, and verify:
"    - the buffer contains only yesterday's date and time
"    - the buffer cannot be modified or written
"
" 2. open `./test/foo.md`, and verify:
"    - the buffer doesn't contain "---test start---" or "---test end---"
"      marker lines
" 3. `:!cat ./test/foo.md`, and verify:
"    - the first line of the file is "---test start---"
"    - the last line of the file is "---test end---"
"    - the rest of the file matches what is shown in the buffer (i.e. in step 2)
"
" 4. modify something in `./test/foo.md` and save. Verify:
"    - the buffer doesn't contain "---test start---" or "---test end---"
"      marker lines
" 5. `:!cat ./test/foo.md`, and verify:
"    - the first line of the file is "---test start---"
"    - the last line of the file is "---test end---"
"    - the rest of the file matches the change you just made in step 4

" TestReader reads the file as normal, and drops the first and last line before loading it into a
" vim buffer
function! TestReader(filename)
  let l:lines = []
  if (filereadable(a:filename))
    let l:lines = readfile(a:filename)[1:-2]
  endif
  return l:lines
endfunction

" TestWriter adds a marker line to the start and end of the buffer before writing it to a file as
" normal
function! TestWriter(filename, lines)
  let l:transformedLines = ["---test start---"] + a:lines + ["---test end---"]
  call writefile(l:transformedLines, a:filename)
endfunction

function! GetTime(filename)
  return systemlist('date --date='.fnamemodify(a:filename, ':t:r'))
endfunction

let s:virtual_file_handlers = {
      \   'test/*.md': {
      \     'writer': 'TestWriter',
      \     'reader': 'TestReader'
      \   },
      \   '*.time': {'reader': 'GetTime'}
      \ }

call virtual_files#addHandlers(s:virtual_file_handlers)
