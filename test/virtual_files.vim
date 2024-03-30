" This is a test configuration that uses every feature of the plugin. To test
" the plugin, try the following:
"
" Setup: vim -c 'so test/virtual_files.vim'
"
" Test readonly virtual files
" 1. open `yesterday.time`, and verify:
"    - the buffer contains only yesterday's date and time
"    - the buffer cannot be modified or written
"
" Test read/write virtual files
" 1. open `./test/foo.md`, and verify:
"    - the buffer doesn't contain "---test start---" or "---test end---"
"      marker lines
" 2. `:!cat ./test/foo.md`, and verify:
"    - the first line of the file is "---test start---"
"    - the last line of the file is "---test end---"
"    - the rest of the file matches what is shown in the buffer (i.e. in step 2)
"
" 3. modify something in `./test/foo.md` and save. Verify:
"    - the buffer doesn't contain "---test start---" or "---test end---"
"      marker lines
" 4. `:!cat ./test/foo.md`, and verify:
"    - the first line of the file is "---test start---"
"    - the last line of the file is "---test end---"
"    - the rest of the file matches the change you just made in step 4
"
" Test error handling on read
" 1. open `./test/foo.readerror` and verify
"    - an error message is shown, identifying that something went wrong while
"      loading the file
"    - the error message includes the file being read
"    - the error message includes the string "Throwing an error to test read error handling" from the original error
"
" Test error handling on write
" 1. open `./test/foo.writeerror`, modify the file and save
"    - an error message is shown, identifying that something went wrong while
"      writing the file
"    - the error message includes the path to the file being written
"    - the error message includes the original error message (that the directory doesn't exist)
"    - the buffer remains modified
"    - neither ./test/foo.writerror nor ./nonexistentdirectory/foo exist as
"      files in the filesystem

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

function! BadReader(filename)
  throw "Throwing an error to test read error handling"
endfunction

function! BadWriter(filename, lines)
  if isdirectory('nonexistentdirectory')
    throw "Directory nonexistentdirectory exists, but the test assumes that it doesn't"
  endif
  call writefile(a:lines, 'nonexistentdirectory/foo')
endfunction

let s:virtual_file_handlers = {
      \   'test/*.md': {
      \     'reader': 'TestReader',
      \     'writer': 'TestWriter'
      \   },
      \   'test/*.readerror': {
      \     'reader': 'BadReader'
      \   },
      \   'test/*.writeerror': {
      \     'reader': 'TestReader',
      \     'writer': 'BadWriter'
      \   },
      \   '*.time': {'reader': 'GetTime'}
      \ }

call virtual_files#addHandlers(s:virtual_file_handlers)
