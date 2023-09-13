let s:lib = g:danvim.lib

function! s:lib.FindDirsFromBaseVars(from)
	for dir in a:from
		let expanded = expand(dir)
		if isdirectory(expanded)
			return expanded
		endif
	endfor
	throw "Could not find a dir from any of " . string(a:from)
endfunction


finish

let s:translate_buffer = v:null
function <SID>TranslatePaneViewport()
	if s:translate_buffer == v:null
		let s:translate_buffer = bufnr()
	else
		execute "buffer " . s:translate_buffer
		let s:translate_buffer = v:null
	endif
endfunction






function! <SID>ExtractExtension( from )
	return 	trim( matchstr( a:from, s:file_extension ) )
endfunction


function! <SID>ReadFromFile( file )
	return readfile( a:file )
endfunction


function! <SID>WriteToFile( content, file )
	try
		return writefile( a:content, a:file )
	catch
		echo "Could not write to file, " . a:file . ", " . v:exception
		return 
	endtry
endfunction


function! <SID>StrPad( what, with, upto )

	let padded = a:what

	while len( padded ) < a:upto
		let padded .= a:with
	endwhile

	return padded

endfunction



func! <SID>MakeEscape(matter)

	return escape
		\(
			\a:matter, 
			\'\" .'
		\)

endfunction

function! <SID>AreWeInAnWorkspaceFile()
	
	return match( bufname(), s:workspaces_pattern )

endfunction



function! <SID>CDAtThisFile(level)

	let to_lcd = expand("%:h")
	execute a:level . " " . to_lcd
	echo "Current " . a:level  . "is now " . to_lcd

endfunction

function! <SID>LocalCDAtFirstRoof()

	let to_lcd = <SID>GetRoofDir()

	if to_lcd < 0
		return
	endif

	execute "lcd " . to_lcd
	echo "Current lcd is now " . to_lcd

endfunction

function! <SID>SharpSplits( JK )

	split
	execute "wincmd " . a:JK
	call <SID>ShortcutToNthPertinentJump( 1, "Workspaces" )

endfunction




function! <SID>ViInitialWorkspace()

	try
		let dir = <SID>FindMyDirFromBaseVars( s:workspaces_dir )
	catch
		echo v:exception
		return 0
	endtry

	let guesses = []
	for a in s:initial_workspace_tries	
		let guess = dir . "/" . a . ".workspaces"
		call add(guesses, guess)
		if file_readable( guess  )
			execute "vi " . guess
			return
		endif
	endfor

	echo "Could not reach initial workspace, looked for in: " . string(guesses)


endfunction

function! <SID>CopyRegisterToFileAndClipboard( )

	let tmp = @" 
	call <SID>WriteToFile( [ tmp ], s:bridge_file )
	call system( s:clipboard_commands[ 0 ] . " -- " . shellescape(tmp) )
"	call system( s:clipboard_commands[ 0 ] . " < " . s:bridge_file )
	echo "Copied \"... " . trim( matchstr( tmp, '.\{1,50}' ) ) . " ...\" to main clipboard"

endfunction


function! <SID>PasteFromClipboard( only_to_main_register )

	let from_regular_clipboard = systemlist( s:clipboard_commands[ 1 ] )

	if a:only_to_main_register == v:false
		call append( line("."), from_regular_clipboard )
	else
		echo "Clipboard has been put to main register"
		let @" = join( from_regular_clipboard, "\n" )
	endif

endfunction
