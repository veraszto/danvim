


function! <SID>PopupJumps( )
	
	try
		nunme jumps
	catch
	endtry

	let jumps = <SID>ChooseBestPlaceToGetJumps( -1, "Traditional" )

	for jump in jumps

		execute "nmenu jumps." . <SID>MakeEscape( <SID>MakeJump( jump ) ) . " " . 
			\ ":wa <Bar> try <Bar> buffer " . jump["bufnr"]  . " " . 
			\ "<Bar> catch <Bar> echo \"Could not buf:\" . v:exception <Bar> endtry<CR>" 

	endfor

	if len( jumps ) > 0
		popup jumps
	else
		echo "No jumps to fill the list popup"
	endif

endfunction



function! <SID>PopupWorkspaces( )
	
	try
		nunme workspaces
	catch
	endtry

	let jumps = <SID>CollectPertinentJumps( -1, "Workspaces" )

	for jump in jumps

		execute "nmenu workspaces." . <SID>MakeEscape( <SID>MakeJump( jump ) ) . " " . 
			\ ":wa <Bar> try <Bar> buffer " . jump["bufnr"]  . " " . 
			\ "<Bar> catch <Bar> echo \"Could not buf:\" . v:exception <Bar> endtry<CR>" 

	endfor

	if len( jumps ) > 0
		popup workspaces
	else
		echo "No workspaces to fill popup"
	endif

endfunction

function! <SID>ShortcutToNthPertinentJump( nth, filter )

	let jumps = <SID>ChooseBestPlaceToGetJumps( a:nth, a:filter )
	let jump = get( jumps, a:nth - 1, {} )
	if jump == {} 
		echo "JBufs did not reach length of " . a:nth
		return 0
	endif

	execute "try | wa | buffer " . jump["bufnr"] . 
				\ " | catch | echo \"Could not buf:\" . v:exception | endtry" 
	return 1

endfunction

function! <SID>MakeJump( jump )

"	let built =  "b:" .
"		\ <SID>StrPad( a:jump["bufnr"], " ", 4 ) . 
"		\ matchstr( bufname( a:jump["bufnr"] ), s:tail_file ) .
"		\ getbufvar( a:jump["bufnr"], "jBufs_overlay_amend" )
"	return built

	let bufname = bufname( a:jump["bufnr"] )

	let tailed = matchstr( bufname , s:tail_with_upto_two_dirs )
	
	if len( tailed ) == 0
		let tailed = "(?)" . bufname
	endif

	if isdirectory( bufname )
		let hold = tailed
		let tailed  = "(DIR)" . hold
	endif

	let cwd = getcwd()

	if ( ( cwd . "/" . tailed ) == ( cwd . "/" . bufname ) )
		let hold = "@ " . tailed
		let tailed = hold
	endif


	return  tailed .
		\ getbufvar( a:jump["bufnr"], "jBufs_overlay_amend" )

endfunction

function! <SID>PopupBuffers()

	let buffers = getbufinfo()

	try
		nunme buffers
	catch
	endtry
	let counter = 0
	for buffer in buffers

		if len( get( buffer, "name") ) == 0 ||
			\ get( buffer, "listed" ) == 0

			continue
		endif
		execute "nmenu buffers." . <SID>MakeEscape( <SID>BuildBufferPopupItem( buffer ) ) . 
			\ " :wa <Bar> buffer" . get(buffer, "bufnr")  . "<CR>"
		let counter += 1
	endfor
	if counter > 0
		popup buffers
	else
		echo "No eligible buffers to fill the list popup"
	endif

endfunction

function! <SID>BuildBufferPopupItem( buffer )

	let label = "buf: " . 
		\ <SID>StrPad( get(a:buffer, "bufnr"), " ", 3 ) . 
		\ matchstr( get(a:buffer, "name"), s:tail_file )

	return label

endfunction


function! <SID>GetThisFilePopupMark()

	try
		let dir = <SID>FindMyDirFromBaseVars(s:popup_marks_dir)
	catch
		echo v:exception
		return 0
	endtry

	let to_expand = dir . "/" . expand("%:t") . ".vim.shortcut"
	let file = expand( to_expand )
	echo "GetThisFilePopupMark: " . file
	return file 

endfunction

function! <SID>EditMarksFile()

	let file_popup = <SID>GetThisFilePopupMark()
	if file_popup == v:false
		return
	endif
	execute "vi " . file_popup

endfunction

func! <SID>PopupMarksShow()

	let popup_file = <SID>GetThisFilePopupMark()

	try
		let b:marks = <SID>ReadFromFile( popup_file )
		if len( b:marks ) == 0
			throw 0
		endif
	catch
		echo "Marks' empty"
		return
	endtry


	try
		nunme mightynimble
	catch
	endtry
	
	let jump = v:false	
	let there_is_a_menu = v:false		
	let counter = 0

	for each_label in b:marks

		let search_for = get( b:marks, counter + 1 )

		let len_each_label = len( trim( each_label ) )
		let len_search_for = len( trim( search_for ) )
"		echo each_label . "(" . len_each_label  . "): " . search_for . "(" . len_search_for . ")"

		if jump == v:true ||
				\ len_each_label == 0 || 
				\ len_search_for == 0 

			let counter += 1
			let jump = v:false
			continue

		endif
		
		let jump = v:true

		let to_execute = "nmenu mightynimble." . 
			\ <SID>MakeEscape( <SID>StrPad( each_label, " ", 50 ) . search_for ) .
			\ " :call <SID>PopupChosen(" . ( counter + 1 ) . ")<CR>"

		execute to_execute
		let counter += 1
		let there_is_a_menu = v:true		
	endfor

	if there_is_a_menu == v:true
		popup mightynimble
	else
		echo "Not showing this empty content -> " . b:marks->join("//")
	endif

endfunction

"\PopupChosen
func! <SID>PopupChosen( index )
			
	let item = b:marks[a:index]
	echo item
	call <SID>MakeSearchNoEscape( item, "sw" )
	let removed = remove(b:marks, a:index - 1, a:index ) 

	let len_removed = len( removed )

	for a in range( len_removed )
		call insert( b:marks, removed[ len_removed - 1 - a ] )
	endfor

	normal zz

	let popup_file = <SID>GetThisFilePopupMark()

	if popup_file == v:false
		return
	endif

	call <SID>WriteToFile( b:marks, popup_file )
	
endfunction
