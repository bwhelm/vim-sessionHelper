" Custom command-line completion
function! ListSessionsCompleteFilter(filter) abort  " {{{
    let sessionList = glob(g:sessionHelperDirectory . "*.vim", 0, 1)
    let sessionList = filter(sessionList, "v:val =~ '/sessions/" . a:filter . "'")
    call map(sessionList, '<SID>extractSessionFromFile(v:val)')
    return join(sessionList, "\n")
endfunction " }}}
function! sessionHelper#ListSessionsComplete(...) abort  " {{{
    return ListSessionsCompleteFilter('\(adhoc-\|autosave\)')
endfunction " }}}
function! sessionHelper#ListSessionsOpenComplete(...) abort " {{{
    return ListSessionsCompleteFilter('')
endfunction " }}}

function! s:extractSessionFromFile(filename, ...) abort  " {{{
    " determine filter (using default if not specified)
    let filter = a:0 == 1 ? a:1 : '\(adhoc-\|autoload-\)\?'
    return matchstr(a:filename, '/sessions/' . filter . '\zs.*\ze\.vim')
endfunction " }}}

function! s:sessionChoose(command) abort  " {{{
    " Have user choose session from list, returning filename
    let sessionList = glob(g:sessionHelperDirectory . "*.vim", 0, 1)
    let sessionList = map(sessionList, "<SID>extractSessionFromFile(v:val, '')")
    let permList = []
    let adhocList = []
    let autosaveList = []
    for session in sessionList
        if session =~ '^adhoc'
            call add(adhocList, session)
        elseif session =~ '^autosave'
            call add(autosaveList, session)
        else
            call add(permList, session)
        endif
    endfor
    if len(adhocList) > 0
        echo "ADHOC SESSIONS"
        for i in range(1, len(adhocList))
            echo i . '.' adhocList[i - 1][6:]
        endfor
    endif
    let orderedList = adhocList
    let total = len(adhocList)
    if len(permList) > 0 && a:command !=# "delete"
        echo "PERMANENT SESSIONS"
        for i in range(total + 1, total + len(permList))
            echo i . '.' permList[i - total - 1]
        endfor
        let total += len(permList)
        let orderedList += permList
    endif
    if len(autosaveList) > 0
        echo "AUTOSAVED SESSIONS"
        for i in range(total + 1, total + len(autosaveList))
            echo i . '.' autosaveList[i - total - 1][9:]
        endfor
        let total += len(autosaveList)
        let orderedList += autosaveList
    endif
    let prompt = a:command ==# "delete" ? 'Enter number of session to DELETE: ' : 'Enter number of session to open: '
    let choice = input(prompt)
    redraw
    if choice =~ '\d\+' && choice > 0 && choice <= len(orderedList)
        let chosenFile = orderedList[choice - 1]
    else
        redraw
        return "ABORT"
    endif
    return g:sessionHelperDirectory . chosenFile . '.vim'
endfunction " }}}

function! s:getSessionFile(session, command) abort  " {{{
    " If session command has no argument, have user choose session file;
    " otherwise locate relevant session file.
    if a:session == ""
        let sessionFile = <SID>sessionChoose(a:command)
        if sessionFile == ""
            echohl Comment
            echo "Aborting."
            echohl None
            return "ABORT"
        endif
    else
        let sessionFile = g:sessionHelperDirectory . 'adhoc-' . a:session . ".vim"
        if !filereadable(sessionFile)
            let sessionFile = g:sessionHelperDirectory . a:session . ".vim"
            if !filereadable(sessionFile)
                echohl WarningMsg
                echo "Cannot find session file, '" . a:session . "'."
                echohl None
                return "ABORT"
            endif
        endif
    endif
    return sessionFile
endfunction " }}}

function! sessionHelper#SessionOpen(session) abort  " {{{
    " Open session file
    let sessionFile = <SID>getSessionFile(a:session, "open")
    if sessionFile !=# "ABORT"
        echo "Opening session " . <SID>extractSessionFromFile(sessionFile, '\(adhoc-\)\?') . "."
        execute "silent source" sessionFile
        " Save last session file only if adhoc session
        if sessionFile =~# '/sessions/adhoc-'
            let g:sessionHelperLastSession = sessionFile
        endif
    endif
endfunction " }}}

function! sessionHelper#SessionDelete(session) abort  " {{{
    " Delete session file
    let sessionFile = <SID>getSessionFile(a:session, "delete")
    if sessionFile !=# "ABORT"
        if sessionFile !~# '/sessions/\(adhoc-\|autosave-\)'
            echo "Will not delete permanent session!" sessionFile
            return
        endif
        call delete(sessionFile)
        echo "Session " . <SID>extractSessionFromFile(sessionFile, '\(adhoc-\)\?') . " deleted."
        if exists('g:sessionHelperLastSession') && sessionFile == g:sessionHelperLastSession
            unlet g:sessionHelperLastSession
        endif
    endif
endfunction " }}}

function! sessionHelper#SessionOpenDelete(session) abort  " {{{
    " Delete session file
    let sessionFile = <SID>getSessionFile(a:session, "delete")
    if sessionFile !=# "ABORT"
        let sessionName = <SID>extractSessionFromFile(sessionFile)
        call <SID>SessionOpen(sessionName)
        call <SID>SessionDelete(sessionName)
    endif
endfunction " }}}

function! sessionHelper#SessionSave(session) abort  " {{{
    " Save session file
    let session = a:session
    if session == ""
        if exists("g:sessionHelperLastSession")
            let session = <SID>extractSessionFromFile(g:sessionHelperLastSession, '\(adhoc-\)\?')
        else
            echohl WarningMsg
            echo "Please provide a session name!"
            echohl None
            return
        endif
    endif
    let sessionFile = g:sessionHelperDirectory . 'adhoc-' . session . ".vim"
    if a:session == ""
        echo "Reusing session:" session . "."
    elseif filereadable(sessionFile)
        echohl WarningMsg
        echo "Overwrite" session "(y/N)?"
        echohl None
        let answer = getcharstr()
        if answer !~? "y"
            redraw | echo "Aborting."
            return
        endif
    else
        echo "Creating" session "session."
    endif
    execute "mksession!" sessionFile
    redraw | echo "Session file" session "written."
    if sessionFile =~# '/sessions/adhoc-'
        let g:sessionHelperLastSession = sessionFile
    endif
endfunction " }}}
