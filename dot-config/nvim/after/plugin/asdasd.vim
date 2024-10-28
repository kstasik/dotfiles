
function! OnTermClose()
    " Try to move the cursor to the last line containing text
    try
        $;?.
    catch
        " The buffer is empty here. This shouldn't ever happen
        return
    endtry
    " Is the last line an error message?
    if match(getline('.'), 'make: \*\*\* \[[^\]]\+] Error ') == -1
        call feedkeys('a ')
    endif
endfunction

augroup MY_TERM_AUGROUP
    autocmd!
    au TermClose * silent call OnTermClose()
augroup END


function! asdasd#cmd(args) abort
    " Trim trailing spaces. This is necessary since :terminal command parses
    " trailing spaces as an empty argument.
    let args = substitute(a:args, '\s\+$', '', '')
    if exists('g:cargo_shell_command_runner')
        let cmd = g:cargo_shell_command_runner
    elseif has('terminal')
        let cmd = 'terminal'
    elseif has('nvim')
        let cmd = 'noautocmd new | terminal'
    else
        let cmd = '!'
    endif
    execute cmd 'make' args
endfunction


function! asdasd#new(args)
    call asdasd#cmd("new " . a:args)
    cd `=a:args`
endfunction

" command! -buffer -nargs=+ Asdasd call asdasd#cmd(<q-args>)
command! -nargs=+ Asdasd call asdasd#cmd(<q-args>)


