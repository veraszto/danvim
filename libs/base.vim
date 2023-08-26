let s:translate_buffer = v:null
function <SID>TranslatePaneViewport()
	if s:translate_buffer == v:null
		let s:translate_buffer = bufnr()
	else
		execute "buffer " . s:translate_buffer
		let s:translate_buffer = v:null
	endif
endfunction

function! <SID>FromDirToFiles(dir_or_file, init)
	let list = a:init
	for each in a:dir_or_file
		if isdirectory(each)
			call <SID>FromDirToFiles(<SID>ReadDirs(each), list)
		elseif filereadable(each)
			call add(list, each)
		endif
	endfor
	return list
endfunction

function! <SID>TabJump()
	let l:count = tabpagenr("$")	
	let current = tabpagenr()
	let middle = l:count / 2 + 1
	if current != middle
		execute "normal " . middle  . "gt"
	else
		tabrewind
	endif
endfunction


function! <SID>MakeHTML()
	let tag = matchstr(getline("."), '[[:alnum:]\._-]\+')
	let indent = matchstr(getline("."), '^\(\t\|\s\)\+')
	call setline(".", indent . "<" . tag . ">")
	call append(".", indent . "</" . tag . ">")
endfunction

function! <SID>FormatJSON( )
	wa
	call <SID>JobStartOutFiles($MY_BASH_DIR . "/format_json.sh")
endfunction

function! <SID>SayHello( msg )

	if len( a:msg ) <= 0
		return
	endif

	call popup_create
		\(
			\ a:msg,
			\ #{
				\ time: 3000,
				\ line:13,
				\ highlight: "InitialMessage",
				\ padding: [ 2, 6, 1, 6 ],
				\ border: [ 0, 0, 1, 0],
				\ borderchars: ["_", "", "_", ""]
			\ }
		\)

endfunction

function! <SID>ShowMeColors()

	let counter = 0xFF 

	for a in range( counter ) 

		let inverse = counter - a
		execute "highlight MyHighlight" .
					\ " ctermfg=" . ( "white" ) . 
					\ " ctermbg=" . a

		echohl MyHighlight
		echo "ctermbg:" . a . ",  Hello how are you?"
		echohl None
	endfor

endfunction

function! <SID>RefreshAll()

	let this_tab = tabpagenr()
	let this_viewport = winnr()
	let running = "running"
	tabdo windo 
		\ try |
			\ if term_getstatus(bufnr()) != running | silent edit! | endif |
		\ catch |
			\ echo "Tab:" . tabpagenr() . ", Buf:" . bufnr() . ") [" . bufname() . "], " .
			\  v:exception |
		\ endtry

	tabdo wincmd h

	execute "tabn " . this_tab
	execute this_viewport . " wincmd w" 
		
	"\ echo getbufinfo(winbufnr(winnr())) |

	echo "Executed forced edit(:e!) throught all active buffers!"
	

endfunction

function! <SID>SourceCurrent_ifVim()
	let l:extension = <SID>ExtractExtension( expand("%") )
	if  l:extension == ".vim"
		let l:this_file = expand( "%" )
		try
			write
			echo "Sourcing " . l:this_file
			execute "source " . l:this_file
		catch
			echo v:exception
		endtry
	else
		echo "Is this a vim script? it is stated as " . l:extension
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

function! <SID>FindMyDirFromBaseVars( from )

	for a in a:from
		let expanded = expand( a )
		if isdirectory( expanded  )
			return expanded
		endif
	endfor
	throw "Could not find a dir from any of " . string(a:from)

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

function! <SID>MoveTo( direction )

	let this_win = winnr()
	let last_win = winnr("$")


	if ( a:direction =~ "^up$" )
		if this_win > 1
			wincmd k
		else
			wincmd b
		endif
	else
		if this_win < last_win
			wincmd j
		else
			wincmd t
		endif
	endif

" As winheight is 999, the option below is not necessary
"	wincmd _

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

function! <SID>SmartReachWorkspace( )

	try
		let dir = <SID>FindMyDirFromBaseVars(s:workspaces_dir)
	catch
		echo v:exception
		return 0
	endtry

	call <SID>GoThroughActiveBuffers( s:workspaces_pattern, "wincmd q", v:true )

	if <SID>AreWeInAnWorkspaceFile() >= 0
		let starting_from_this = expand("%:t")
		let without_workspaces = substitute(starting_from_this, '.workspaces', "", "")
		let one_dir_up = substitute(without_workspaces, '\.[^\.]\{-}$', "", "")
		let to_bars = "/" . substitute(one_dir_up, '\.', "/", "g")
		let starting_from_this = to_bars
	else
		let starting_from_this = expand("%:p:h")
	endif
	let to_points = substitute(starting_from_this, '/', ".", "g")
	let build_file_name = matchstr(to_points, '\(^.\)\@<=.\+')

	let safe_guard = 0

	while 1
		let searching = dir . "/" . build_file_name . ".workspaces"
		if filereadable( searching  ) 
			try | wa | catch | echo "Could not save all buffers! No worries!" | endtry
			execute "vi " . searching
			break
		endif
		let one_dir_up = substitute(build_file_name, '\.[^\.]\{-}$', "", "")
		if match(one_dir_up, '\.') < 0
			call <SID>ViInitialWorkspace()
			break
		endif
		let build_file_name = one_dir_up
		let safe_guard += 1
		if safe_guard > 20
			break
		endif
	endwhile

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
