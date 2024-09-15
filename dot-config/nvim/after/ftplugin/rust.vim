" author: https://github.com/woshilapin/dot/blob/34f95098ac6c34500b30f421774cf74ead2f00a2/vim/ftplugin/rust_Rust.vim#L81-L144 
" if exists("b:did_ftplugin")
"	finish
" endif
" let b:did_ftplugin = 1

"""" PARAMETERS
setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=0
setlocal expandtab
setlocal list
compiler cargo
noremap <F5> <Esc>:Cargo check --all-features<Enter>
noremap <leader>t <Esc>:call <SID>rust_execute_test()<Enter>

if has("autocmd")
	autocmd BufWritePre <buffer> call rustfmt#Format()
endif

""" copied from: https://github.com/rust-lang/rust.vim/blob/master/autoload/cargo/quickfix.vim
""" function! cargo#quickfix#CmdPre() abort
"""     if &filetype ==# 'rust' && get(b:, 'current_compiler', '') ==# 'cargo' &&
"""          \ &makeprg =~ '\V\^cargo\ \.\*'
"""         " Preserve the current directory, and 'lcd' to the nearest Cargo file.
"""         let b:rust_compiler_cargo_qf_has_lcd = haslocaldir()
"""         let b:rust_compiler_cargo_qf_prev_cd = getcwd()
"""         let b:rust_compiler_cargo_qf_prev_cd_saved = 1
"""         let l:nearest = fnamemodify(cargo#nearestRootCargo(0), ':h')
"""         execute 'lchdir! '.l:nearest
"""     else
"""         let b:rust_compiler_cargo_qf_prev_cd_saved = 0
"""     endif
""" endfunction
""" 
""" function! cargo#quickfix#CmdPost() abort
"""     if exists("b:rust_compiler_cargo_qf_prev_cd_saved") && b:rust_compiler_cargo_qf_prev_cd_saved
"""         " Restore the current directory.
"""         if b:rust_compiler_cargo_qf_has_lcd
"""             execute 'lchdir! '.b:rust_compiler_cargo_qf_prev_cd
"""         else
"""             execute 'chdir! '.b:rust_compiler_cargo_qf_prev_cd
"""         endif
"""         let b:rust_compiler_cargo_qf_prev_cd_saved = 0
"""     endif
""" endfunction

" vim: set et sw=4 sts=4 ts=8:

let g:syntastic_rust_checkers = []
let g:autofmt_autosave = 1

" Search for a pattern followed immediately by a opening block '{'
function! s:is_opening_block(preblock_pattern)
	let view = winsaveview()
	" If we search for the pattern but we are already on it, we're gonna find 
	" the next one (search forward) or the previous one (search backward) but 
	" not the current one.
	" To avoid this, we move one character forward and we're gonna search 
	" backward.
	execute "normal! l"
	" if we're at the end of the line
	if col(".") == view["col"] + 1
		" move to the beginning of next line
		execute "normal! j0"
	endif
	let [lnum, col] = searchpos(a:preblock_pattern . '\zs{\ze', "b")
	call winrestview(view)
	if lnum == line(".") && col == col(".")
		let result = v:true
	else
		let result = v:false
	endif
	return result
endfunction

function! s:extract_name(pattern)
	let view = winsaveview()
	let lnum = search(a:pattern, "b")
	call winrestview(view)
	let line = getline(lnum)
	let name = matchstr(line, a:pattern)
	return name
endfunction

function! s:is_test_function_block()
	const test_prefix_pattern = '#\[.*test\]\_.\{-}'
	const prefix_pattern = '\<fn\>\s\+'
	const function_name_pattern = '\<\h\w*\>'
	const suffix_pattern = '[<(\s][^{]\+'
	let is_test_function_block = <SID>is_opening_block(test_prefix_pattern . prefix_pattern . function_name_pattern . suffix_pattern)
	if is_test_function_block
		let function_name = <SID>extract_name(prefix_pattern . '\zs\(' . function_name_pattern . '\)')
		return function_name
	endif
	return -1
endfunction

function! s:is_mod_block()
	const prefix_pattern = '\<mod\>\s\+'
	const mod_name_pattern = '\<\h\w*\>'
	const suffix_pattern = '\s\+'
	let is_test_mod_block = <SID>is_opening_block(prefix_pattern . mod_name_pattern . suffix_pattern)
	if is_test_mod_block
		let mod_name = <SID>extract_name(prefix_pattern . '\zs\(' . mod_name_pattern . '\)')
		return mod_name
	endif
	return -1
endfunction

function! s:rust_execute_test()
	const FUNCTION_SEARCH_STATE = "function-search"
	const MOD_SEARCH_STATE = "mod-search"
	const FILE_SEARCH_STATE = "file-search"
	let test_path = []
	let state = FUNCTION_SEARCH_STATE
	let function_found = v:false
	let view = winsaveview()
	let lnum = view['lnum']
	let col = view['col']
	normal! [{
	while lnum != line(".") || col != col(".")
		if state == FUNCTION_SEARCH_STATE
			let function_name = <SID>is_test_function_block()
			if function_name != -1
				let test_path += [function_name]
				let function_found = v:true
				let state = MOD_SEARCH_STATE
			else
				let mod_name = <SID>is_mod_block()
				if mod_name != -1
					let test_path += [mod_name]
					let state = MOD_SEARCH_STATE
				endif
			endif
		elseif state == MOD_SEARCH_STATE
			let mod_name = <SID>is_mod_block()
			if mod_name != -1
				let test_path += [mod_name]
			endif
		endif
		let lnum = line(".")
		let col = col(".")
		normal! [{
	endwhile
	let cargo_arguments = "test --all-features"
	let file_path = []
	for segment in split(expand("%:p:r"), '/')
		" Before 'src', discard every segment of the path
		if segment == "src"
			let cargo_arguments .= " --lib"
			let state = FILE_SEARCH_STATE
		elseif segment == "tests-unknown"
			let cargo_arguments .= " --test " . expand("%:t:r")
			break
		elseif state == FILE_SEARCH_STATE
			" Every segment of the path is now a module (folder or files) at the 
			" exception of `lib.rs` and `main.rs`
			if segment != "lib" && segment != "main" && segment != "mod"
				let file_path += [segment]
			endif
		endif
	endfor

	let test_path = file_path + reverse(test_path)

	if function_found
		let cargo_arguments .= " -- --nocapture --exact "
	else
		let cargo_arguments .= " -- --nocapture "
	endif
	let cargo_arguments .= join(test_path, "::")
	call winrestview(view)
	" Run cargo command
    " echom "asd " . cargo_arguments
	execute "Cargo " . cargo_arguments
    call feedkeys("G")
endfunction
