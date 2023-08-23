function! <SID>SetDictAndGreps( )

	let b:DanVim_grep_files = join(DictsAndGrepsFiles(".grep"), " ")
	execute "setlocal dictionary=" . join( DictsAndGrepsFiles(".dict"), "," )

endfunction

function! <SID>PopupGrep()
	
	if (!exists("b:DanVim_grep_files") || len(b:DanVim_grep_files) == 0)
		echo "b:DanVim_grep_files is not filled, were there grep files for " . expand("%:e") . " files types?"
		return
	endif
	let looked_for = expand("<cword>")
	if len(looked_for) <= 0
		echo "Are you with the cursor over the word you want to look for?"
		return
	endif
	let grep_implementation = "grep -i " . looked_for  . " " . b:DanVim_grep_files
	let grep = systemlist(grep_implementation)
	if len(grep) <= 0
		echo "Nothing has been found with " . looked_for
		return
	endif
	try
		aunmenu DanVimGrepCompletionMenu
	catch
	endtry

	let menu = []
	for eligible in grep
		call add
		\ (
			\ menu, "amenu DanVimGrepCompletionMenu." . <SID>MakeEscape(eligible) . " " . 
			\ "bved\"='" . eligible . "'<CR>p:let @g = '" . eligible . "'<CR>"
		\ )
	endfor


	for each_menu in menu
		execute each_menu
	endfor

	popup DanVimGrepCompletionMenu

endfunction


function! DictsAndGrepsFiles(dict_grep)
	try
		let dir = <SID>FindMyDirFromBaseVars(s:dictionaries_dir)
	catch
		echo v:exception
		return []
	endtry

	let potential_dicts = expand( dir . "/*", 1, 1)
	let this_type = expand("<afile>:e")

	let selected = []
	for a in potential_dicts
		let type = matchstr( a, '[^/]\+$' )
		if match( type, this_type . a:dict_grep ) >= 0
			call add( selected, a )
		endif
	endfor
	return selected
endfunction
