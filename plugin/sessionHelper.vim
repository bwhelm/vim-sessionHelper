" Set sessionHelper directory
if !exists("g:sessionHelperDirectory")
    let g:sessionHelperDirectory = expand("$HOME") . "/.vim/sessions/"
endif
if !isdirectory(g:sessionHelperDirectory)
    call mkdir(g:sessionHelperDirectory)
endif

" Commands
command! -complete=custom,sessionHelper#ListSessionsComplete -nargs=? SessionOpen :call sessionHelper#SessionOpen("<args>")
command! -complete=custom,sessionHelper#ListSessionsComplete -nargs=? SessionSave :call sessionHelper#SessionSave("<args>")
command! -complete=custom,sessionHelper#ListSessionsComplete -nargs=? SessionDelete :call sessionHelper#SessionDelete("<args>")
command! -complete=custom,sessionHelper#ListSessionsComplete -nargs=? SessionOpenDelete :call sessionHelper#SessionOpenDelete("<args>")
