let s:tail_file = '[._[:alnum:]-]\+$'
let s:tail_with_upto_two_dirs = '\([^/]\+/\)\{,2}[^/]\+$'
let s:file_extension = '\.[^./\\]\+$'
let s:file_extension_less = '^.\+\(\.\)\@='
let s:workspaces_pattern = '\.workspaces$'
" The order of the array contents below matters
let s:exclude_from_jbufs = [ s:workspaces_pattern, '\.shortcut$' ]
let s:max_file_search = 36
let s:we_are_here = '^\[\(we.are.here\|base\)\]'
let s:search_by_basic_regex = '^\[search\]'
let s:traditional_keybinds = [ "Home", "End", "pgUp", "pgDown" ]
let s:len_traditional_keybinds = len( s:traditional_keybinds )
let s:elligible_auto_global_marks_letters = [ "L", "V", "R", "W", "D", "G" ]
let s:elligible_auto_cycle_local_marks_letters = 
	\ ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]

"let s:tree_special_chars = '^\(\%u2500\|\%u2502\|\%u251C\|\%u2514\|\%xA0\|[[:space:]]\)\+'
"let s:types_of_overlays = [ "Traditional", "Workspaces" ]
let s:types_of_overlays = [ "Traditional" ]

let s:tab_vars_names = ["title", "workspaces"]
let s:global_vars_names = ["DanVim_save_loader_name", g:DanVim_fluid_flow_VAR_NAME]
let s:global_options_names = ["tabstop", "softtabstop", "shiftwidth", "expandtab"]
let s:global_options_names_toggle_mode = ["expandtab"]
let s:overlay_allowed_to_show = v:true
let s:tmp_vim_script_buffers_loader = "/tmp/buffers.loader.vim"


if exists("s:this_has_been_loaded") == v:false
	let s:this_has_been_loaded = v:true
	let s:popup_winids = {}
	let s:last_win_tab = [0, 0]
	let s:automatic_scp = 0
	call <SID>StartUp()
	call <SID>SayHello( s:initial_message )
	call <SID>MakeInitialFluidFlow()
endif



function! <SID>BuffersMatteringNow()

	let current_tab = tabpagenr()
	for tab in range(1, tabpagenr("$"))
		let mattering = gettabvar( tab, "mattering", v:false )
		if mattering == v:true
			let buf_number = bufnr()
			execute "tabn " . tab
			exec "sbuffer " . buf_number
		endif
	endfor

	if ! exists("buf_number")
		let buf_number = bufnr()
		tabnew
		let t:title = "MattersNow"
		let t:mattering = v:true
		exec "buffer " . buf_number
	endif

	execute "tabn " . current_tab

endfunction

function! <SID>JobStartAfterParty()

	let offset = 0
	let range = range( tabpagewinnr(".", "$") )

	for viewport in range 
		
		let viewport_to_focus = ( viewport + offset + 1 )
		execute  viewport_to_focus . "wincmd w"

		if exists("b:DanVim_this_buf_is_output")
			echo expand("%")
			let offset -= 1
			quit!
		endif

	endfor
	
endfunction

function! <SID>NavigateThroughLocalMarksAndWorkspaces( go )

	if <SID>AreWeInAnWorkspaceFile() > 0

		if a:go =~ '^down$'
			call cursor(line(".") - 1, 1)
			let line = search( s:we_are_here, "bnw" )
		else
			let line = search( s:we_are_here, "nw" )
		endif
		let line += 1
		call cursor( line, 1 )
		return
	endif

	call <SID>LocalMarksAutoJumping( a:go )

endfunction


function! <SID>LocalMarksAutoJumping( go )


	if ! exists("b:local_marks_auto_jumping")
		let b:local_marks_auto_jumping = [ 0, 0 ]
	endif

	let len_elligible = len( s:elligible_auto_cycle_local_marks_letters )

	if b:local_marks_auto_jumping[ 1 ] >= len_elligible
		echo "No marks found"
		let b:local_marks_auto_jumping[ 1 ] = 0
		return
	endif

	if a:go =~ '^up$'
		let b:local_marks_auto_jumping[ 0 ] += 1
	else
		let b:local_marks_auto_jumping[ 0 ] -= 1
	endif

	let letter = 
		\ s:elligible_auto_cycle_local_marks_letters
		\[ 
			\ b:local_marks_auto_jumping[ 0 ] % len_elligible
		\]

	normal m'
	let mark_pos = getpos( "'" . letter )

	if mark_pos[ 1 ] > 0
		call setpos( ".", mark_pos )
		redraw
		echo "At mark: " . letter . ") " . getline( mark_pos[ 1 ] ) 
		normal zz
		let b:local_marks_auto_jumping[ 1 ] = 0
		return
	endif

	let b:local_marks_auto_jumping[ 1 ] += 1

	call <SID>LocalMarksAutoJumping( a:go )


endfunction

function! <SID>ClearHighlights( list )

	for a in a:list
		execute "highlight clear " . get( a , 0 )
	endfor

endfunction

function! <SID>MarksAutoCyclingErasing( index, joined_letters, letters )

	if v:count == 0
		return v:false
	endif

	let save_index = a:index 
	let s:counter_cycle_bufs_{a:joined_letters} -= 1
	let prev_index = s:counter_cycle_bufs_{a:joined_letters} % len( a:letters )

	if v:count > 2

		echo "Erasing all"
		for a in s:elligible_auto_global_marks_letters
			execute "delm " . a
			echo "Erased " . a
		endfor
		return 1

	endif

	execute "delmark " . a:letters[ prev_index ]
	echo a:letters[ prev_index ] . " has just been deleted"

	if v:count > 1
		execute "delmark " . a:letters[ save_index ]
		echo a:letters[ save_index ] . " has just been deleted"			
	endif
	return 1


endfunction

function! <SID>WrapperCycleThroughLetters( start, amount )

	let select = []
	for a in range( a:start, a:start + a:amount - 1 )
		call add( select, s:elligible_auto_global_marks_letters[ a ] )
	endfor
	call <SID>CycleTwoLetters( select )

endfunction

function! <SID>RemoveLastTwoLettersCycle()

	if ! exists("s:last_two_letters_cycle")
		echo "There are not marks to remove"
		return
	endif

	let letters = join( s:last_two_letters_cycle, " ")

	echo "Removing " .  letters

	execute "delm " . letters
 
endfunction

function! <SID>MarkNext()

	let counter = 0
	let length = len( s:elligible_auto_cycle_local_marks_letters )
	while 1

		let try_this = s:elligible_auto_cycle_local_marks_letters[ counter % length ]
		let pos = getpos("'" . try_this )
		if pos[1] == 0
			execute "mark " . try_this
			redraw | echo "Marked " . try_this
			break
		endif
		if counter >= length
			echo "All marks are set!"
			break
		endif
		let counter += 1

	endwhile
endfunction


function! <SID>WrapperHideAndShowPopups()

	let s:overlay_allowed_to_show = ! s:overlay_allowed_to_show

	if s:overlay_allowed_to_show == 0
		for a in s:types_of_overlays
			call <SID>HideAndShowPopups( ["mustnotmatch"], a )
		endfor
	else
		for a in s:types_of_overlays
			call <SID>HideAndShowPopups( <SID>BuildOverlayNameArray( a ), a )
		endfor
	endif

endfunction

function! <SID>GoThroughActiveBuffers( match, do, do_not_perform_when_alone_in_tab )

	let tab_viewport = [ tabpagenr(), winnr() ]

	tabdo 
		\ let last_viewport = winnr("$") |
		\ if last_viewport > 1 || a:do_not_perform_when_alone_in_tab == v:false |
			\ for a in range(last_viewport) |
				\ let viewport = ( a + 1 ) |
				\ if tab_viewport[0] == tabpagenr() && viewport == tab_viewport[1] | continue | endif |
				\ let bufname = bufname(winbufnr(viewport)) |
				\ if match( bufname, a:match) > -1 | 
					\ wa | execute viewport . a:do | endif |
			\ endfor |
		\ endif

	execute "tabnext " . tab_viewport[0]

endfunction

function! <SID>CycleTwoLetters( letters )

	let joined_letters = join( a:letters, "")

"	if joined_letters =~ '^\l\{2}'
"		let add_to_joined = joined_letters . "_" . bufnr()
"		let joined_letters = add_to_joined
"	endif

	if ! exists("s:counter_cycle_bufs_" . joined_letters )
		let s:counter_cycle_bufs_{joined_letters} = 0
	endif

	let s:counter_cycle_bufs_{joined_letters} += 1
	let index = s:counter_cycle_bufs_{joined_letters} % len( a:letters )

	let letter = a:letters[ index ]
	
	let pos = getpos( "'" . letter )

	if <SID>MarksAutoCyclingErasing( index, joined_letters, a:letters ) == 1
		return
	endif

	if pos[1] > 0

		if bufnr() != pos[ 0 ] &&
				\ pos[ 0 ] != 0
			try
				wa
				execute "bu " . pos[ 0 ]
			catch
				echo "Could not reach: '" . letter . ", because: " . v:exception
			endtry
		else
			echo "At mark: " . letter
		endif
		normal m'
"		call setpos( ".", pos ) | execute "normal z\<enter>"
		call setpos( ".", pos ) | normal zz
	else
		echo "Marking letter \"" . letter . "\" here: " . getline(".")
		execute "mark " . letter
	endif

	if index >= 36
		unlet s:counter_cycle_bufs_{joined_letters}
	endif

	let s:last_two_letters_cycle = a:letters	

endfunction

function! <SID>AfterRuntimeAndDo( what )
	
	let l:this_file = expand("%:t") 
	echo "Calling " . a:what . ", with already runtimed Dan.vim expected"
	"This below would give an error, the one that cannot redefine a function while it is being called
	let l:Function = function( "<SID>" . a:what )	
	call l:Function()

endfunction

function! <SID>WorkspacesFilesToBuffer()

	let this_file = expand("%")

	if <SID>AreWeInAnWorkspaceFile() < 0
		echo "We are not in a workspace file " . s:workspaces_pattern
		return {}
	endif

	let this_line = line(".")
	let files = {}
	call cursor(1, 1)
	let last_line = line("$")
	let curly_groups_found = 0

	while 1

		let open = search( '^{', "W" )

		if open == 0
			echo "Opened " . curly_groups_found . " curly groups of files"
			break
		endif

		let curly_groups_found += 1
		
		let roof = <SID>GetRoofDir()

		if roof < 0
			return {}
		endif

		let content_line_number = open + 1
		let content_line_content = getline( content_line_number )

		while 1

			if
				\ match( content_line_content, '^}' ) >= 0 ||
				\ content_line_number > last_line
				break
			endif

			let [ a, b, filtered ] = 
					\ <SID>MatchedAndAllRemoved
					\ (
							\ content_line_content,
							\ [
									\ s:add_as_bufvar,
									\ s:cmd_buf_pattern
							\ ]
					\ )

			let ext = <SID>ExtractExtension( filtered )

			if len( ext ) == 0
				let ext = ".ext.less"
			endif

			if 
				\ match( ext, s:workspaces_pattern ) > -1 ||
				\ len( trim( content_line_content  )  ) == 0

					let content_line_number += 1
					let content_line_content = getline( content_line_number )
					continue
			endif

			if ! exists( "files[ ext ]" )
				let files[ ext ] = []
			endif

			call add( files[ ext ], roof . trim( content_line_content ) )
			
			let content_line_number += 1
			let content_line_content = getline( content_line_number )


		endwhile
	endwhile

	return files

endfunction

function! <SID>StampThisTypeToStatusLine()

	let w:stamp_name = <SID>ExtractExtension( @% )

endfunction

function! <SID>getStamp()
	if exists("w:stamp_name")
		return w:stamp_name
	endif
	return ""
endfunction

"\MakeEscape


function! <SID>OpenWorkspace()

	let files_to_buffer = <SID>WorkspacesFilesToBuffer()

	if files_to_buffer == {}
		return
	endif

	call <SID>TurnOnOffOverlays( 0 )

	let already_stamped = []
	let non_stamped = []

	for a in range( 1, winnr("$") )

		let stamp = getwinvar( a, "stamp_name", -1)
		if  stamp > -1
			call add( already_stamped, [ a, win_getid( a ), stamp ] )
		else
			call add( non_stamped, [ a, win_getid( a ) ] )
		endif
	endfor


	for a in already_stamped

		let keys_files_to_buffer = keys( files_to_buffer ) 

		for b in keys_files_to_buffer 

			let files = files_to_buffer[ b ]
			if b == a[ 2 ]
				call win_gotoid( a[ 1 ] )
				for c in files
					call <SID>SpecialBu( c )
				endfor
				call remove( files_to_buffer, b )
				break
			endif

		endfor

	endfor
	

	for a in non_stamped

		let files_groups = keys( files_to_buffer )

		if len( files_groups ) == 0
			break
		endif

		let a_key_group = files_groups[ 0 ]

		let files = files_to_buffer[ a_key_group ]
		call win_gotoid( a[ 1 ] )
		for c in files
			call <SID>SpecialBu( c )
		endfor

		call remove( files_to_buffer, a_key_group )

		call <SID>StampThisTypeToStatusLine()

	endfor
	
	let keys_files_to_buffer = keys( files_to_buffer ) 

	for b in keys_files_to_buffer
		let files = files_to_buffer[ b ]
		split
		for c in files
			call <SID>SpecialBu( c )
		endfor
		call <SID>StampThisTypeToStatusLine()
	endfor

"No need as winheight is set to 999 and winminheight to 0
"	wincmd _

	call <SID>TurnOnOffOverlays( 1 )

endfunction



function! <SID>IsMatchedWithStamp( matter )

	if ! exists("w:stamp_name")
		return 1
	endif

	if w:stamp_name != <SID>ExtractExtension( a:matter )
		return -1
	endif

	return 0

endfunction




function! <SID>IsMatchedWithExcludeFromTraditionalJBufs( matter )

	let matches = [ 0, -1 ]
	let counter = 0

	for check in s:exclude_from_jbufs

		let matched = match( a:matter, check )
		if matched > - 1 
			let	matches[ 0 ] = 1
			let	matches[ 1 ] = counter
			break
		endif

		let counter += 1

	endfor

	retur matches

endfunction


function! <SID>TraditionalPertinentJumps( bufinfo )

	return <SID>IsMatchedWithExcludeFromTraditionalJBufs( a:bufinfo["name"] )[ 0 ] > 0 ||
				\ <SID>IsMatchedWithStamp( a:bufinfo["name"] ) < 0

endfunction

function! <SID>WorkspacesPertinentJumps( bufinfo )

	return ! ( <SID>IsMatchedWithExcludeFromTraditionalJBufs( a:bufinfo["name"] )[ 1 ] == 0 )

endfunction


function! <SID>CycleLastTwoExcluded()

	let jumps = getjumplist()[0]
	let length = len( jumps )
	let i = length - 1

	while i >= 0
		let jump = jumps[ i ]
		let bufnr = get( jump, "bufnr")
		let bufname = get( getbufinfo( bufnr )[0], "name" )

		if match( bufname, s:workspaces_pattern ) > -1 && bufnr != bufnr()
			execute "try | buffer " . bufnr . " | catch | echo \"Could not buf:\" . v:exception | endtry" 
			break
		endif

		let i -= 1
	endwhile

endfunction


function! <SID>PreparePathsToGenerateVimScriptToLoadBuffers()

	let way_to_goback = [ "cd", "lcd", "tcd" ]
	let this_dir = getcwd( )
	let has_local_dir = haslocaldir( )
	let save = way_to_goback[ has_local_dir ] . " " . this_dir
	cd /
	return save

endfunction

function! <SID>GenerateVimScriptToLoadBuffersOfATab( which )

	let list = []
	let counter = 0
	let options = [ "vi", "split" ]

	for name in s:tab_vars_names

		let tab_var = gettabvar( a:which, name )
		if len( tab_var ) > 0
			call add
			\ ( 
				\ list, "let t:" . name  . " = \"" . tab_var . "\""
			\ )
		endif

	endfor

	let buffers = reverse( tabpagebuflist( a:which ) )
	for a in buffers 

		let index = counter
		if counter > 0
			let index = 1
		endif

		let bufname = bufname( a )

		if trim( bufname ) =~ '^$'
			continue
		endif

		call add( list, options[ index ]  . " " .  bufname )
		let counter += 1

	endfor

"	call add( list, "\twincmd t")
	
"	call add( list, "catch | echo \"Could not load buffers: \" . v:exception | endtry" )
	
	return list

endfunction




function! <SID>PromptSaveOrLoadLoaderName( should_save, from )

	let dir = <SID>FindMyDirFromBaseVars(s:loaders_dir)
	let msg = 
	\ [ 
		\ "Please type a new name or an existing one ",
		\
		\ "as the adjacent sample line below demonstrates:\n" .
		\ "my.awesome.Project SortersAlgorithms\n",
		\
		\ "to save to",
		\
		\ ":\n" . dir . "/my/awesome/Project/SortersAlgorithms.vim\n",
		\
		\ "to save or overwrite the ", 
		\
		\ "state ",
		\ 
		\ "of ",
		\
		\ "this VIM instance ",
		\
		\ "with ALL current active buffers"
	\ ]

	let main_state = "SAVE to"
	if a:should_save == 0
		let msg[0] = "Enter an existing name "
		let msg[2] = "to load from"
		let msg[4] = "to load a "
		let msg[6] = "to "
		let msg[8] = "with the desired project"
		let main_state = "LOAD from"
	endif

	if ( a:from > 1 )
		let msg[6] = "with buffers from current tabpage " . a:from . " up to including the last"
	endif


	let g_danvim_set = ""
	if ! exists("g:DanVim_save_loader_name") || a:should_save == 0
		echo join( msg, "" )
		echohl DiaryDivisorDate 
		echo main_state . ":"
		echohl None
		let input = input("")
		let trimmed_input = trim( input )
		echo "\n"
		echo "Input " . "(" . input . ")"
		let g_danvim_set = "g:DanVim_save_loader_name has just been (re)set to " .
			\ trimmed_input . " in order to save VIM state without being asked for project's name input"
	else
		let trimmed_input = g:DanVim_save_loader_name
		echo "Using previously set name from g:DanVim_save_loader_name: " . g:DanVim_save_loader_name
	endif

	if len( trimmed_input ) <= 0
		if a:should_save == 1
			unlet g:DanVim_save_loader_name
		endif
		throw "Could not " . main_state . " an empty name"
	endif

	let project_context_and_project = split(trimmed_input, '\s') 

	if len(project_context_and_project) < 2
		if a:should_save == 1
			unlet g:DanVim_save_loader_name
		endif
		throw "Please enter a project context and a project name, like this \"my.Stuff BashScripts\", " .
			\ "this way: \"" . trimmed_input . "\" it will not behave like expected"
	endif
	
	if len(g_danvim_set) > 0
		echo g_danvim_set
	endif

	let path_prefix = dir . "/" . 
		\ substitute(project_context_and_project[0], '\.', "/", "g")

	if ! isdirectory(path_prefix)
		call mkdir(path_prefix, "p")
		echo "Created dir: " . path_prefix
	endif

	let path_sufix = project_context_and_project[1] . ".vim"

	let file_name = path_prefix . "/" . path_sufix

	if a:should_save == 1
		let g:DanVim_save_loader_name = trimmed_input
	endif

	return  file_name

endfunction

function! <SID>SaveLoader( from )

	try
		let file_name = <SID>PromptSaveOrLoadLoaderName( 1, a:from )
	catch
		echo v:exception
		return
	endtry

	let last_tab = tabpagenr( "$" )
	let commands = []

	for option in s:global_options_names
		execute "let option_value = &g:" . option
		let is_toggle = 0
		for toggle in s:global_options_names_toggle_mode
			if toggle == option
				let is_toggle = 1
				break
			endif
		endfor
		if is_toggle == 0
			call add(commands, "setglobal " . option . "=" . option_value)
		else
			if option_value == 1
				call add(commands, "setglobal " . option)
			else
				call add(commands, "setglobal no" . option)
			endif
		endif
	endfor

	call add(commands, "")

	let save = <SID>PreparePathsToGenerateVimScriptToLoadBuffers()

	for a in range( a:from, last_tab )
		
		let for_this_tab = <SID>GenerateVimScriptToLoadBuffersOfATab( a )
		call extend( commands,   for_this_tab )
		call extend( commands, [ "", "tabnew" ])

	endfor

	execute save

	call remove( commands, len( commands ) - 1 )

	call add( commands, "tabn 1" )

	for name in s:global_vars_names

		if exists( "g:" . name ) == v:true
			call add(commands, "let g:" . name . " = " . string(g:[name]) )
		endif

	endfor

	call <SID>WriteToFile( commands,  file_name )
	if len(findfile(file_name)) > 0
		echo "Saved overriding loader to " . file_name
	else
		echo "Saved loader to " . file_name
	endif


endfunction

function! <SID>BaseDirToSaveLoader()

	let dir = "cd"
	execute dir
	return dir

endfunction

function! <SID>LoadLoader( )

	try
		let file_name = <SID>PromptSaveOrLoadLoaderName(0, 1)
	catch
		echo v:exception
		return
	endtry


	if filereadable( file_name ) == 0
		echo "\nThe file " . file_name . " is not readable"
		return
	endif

	let initial_tabpage_number = tabpagenr()
	tabnew
	try
		execute "source " . file_name
		echo "Loaded from " . file_name
	catch
		echo "Could not source " . file_name . ", v:exception: " . v:exception
		return
	endtry

	let initial_tab_buffers = tabpagebuflist( initial_tabpage_number )

	if len( initial_tab_buffers ) <= 1 &&
		\ bufname( initial_tab_buffers[ 0 ] ) =~ '^$'
		try
			execute initial_tabpage_number . "tabclose"
		catch
		endtry
	endif
		
endfunction

function! <SID>SaveBuffersOfThisTab()

	let save = <SID>PreparePathsToGenerateVimScriptToLoadBuffers()
	let this_buffers = <SID>GenerateVimScriptToLoadBuffersOfATab( tabpagenr() )
	execute save
	call <SID>WriteToFile
	\ ( 
		\ this_buffers,  
		\ s:tmp_vim_script_buffers_loader
	\ )

	echo "Saved:\n" . join( this_buffers, "\n" ) . "\nto " . s:tmp_vim_script_buffers_loader

endfunction
